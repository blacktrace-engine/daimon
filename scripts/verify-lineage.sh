#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="${1:-state/daimon.json}"
HISTORY_DIR="${2:-state/history}"
AUTHORITY_FILE="${3:-state/authority.json}"

fail() {
  echo "LINEAGE INVALID: $*" >&2
  exit 1
}

[ -f "$STATE_FILE" ] || fail "missing head state: $STATE_FILE"
[ -d "$HISTORY_DIR" ] || fail "missing history directory: $HISTORY_DIR"
[ -f "$AUTHORITY_FILE" ] || fail "missing authority policy: $AUTHORITY_FILE"

IDENTITY=$(jq -er '.identity | select(type == "string" and length > 0)' "$STATE_FILE")
HEAD_GENERATION=$(jq -er '.generation | select(type == "number" and floor == . and . >= 0)' "$STATE_FILE")
HEAD_SHA256=$(sha256sum "$STATE_FILE" | awk '{print $1}')
CURRENT_AUTHORITY_SHA256=$(sha256sum "$AUTHORITY_FILE" | awk '{print $1}')
CURRENT_AUTHORITY_VERSION=$(jq -er '.policy_version | select(type == "number" and floor == . and . >= 1)' "$AUTHORITY_FILE")

mapfile -t FILES < <(find "$HISTORY_DIR" -maxdepth 1 -type f -name '*.json' -printf '%f\n' | sort)
[ "${#FILES[@]}" -gt 0 ] || fail "no lineage records"

PREVIOUS_FILE=""
PREVIOUS_GENERATION=""
LAST_GENERATION=""
LAST_STATE_SHA256=""
AUTHORITY_BINDING_STARTED=0
AUTHORITY_BINDING_GENERATION=""

for name in "${FILES[@]}"; do
  [[ "$name" =~ ^[0-9]{6}\.json$ ]] || fail "unexpected lineage filename: $name"
  file="$HISTORY_DIR/$name"

  generation=$(jq -er '.generation | select(type == "number" and floor == . and . >= 0)' "$file")
  record_identity=$(jq -er '.identity | select(type == "string" and length > 0)' "$file")
  previous_generation=$(jq -er '.previous_generation | select(type == "number" and floor == . and . >= 0)' "$file")
  previous_state_sha256=$(jq -er '.previous_state_sha256 | select(type == "string" and test("^[0-9a-f]{64}$"))' "$file")
  state_sha256=$(jq -er '.state_sha256 | select(type == "string" and test("^[0-9a-f]{64}$"))' "$file")
  verification_method=$(jq -er '.verification.method | select(type == "string" and length > 0)' "$file")

  [ "$record_identity" = "$IDENTITY" ] || fail "$name identity $record_identity != head identity $IDENTITY"
  [ "$generation" -eq $((previous_generation + 1)) ] || fail "$name generation transition is not +1"
  [ "$verification_method" = "external_exact_message" ] || fail "$name has unsupported verification method: $verification_method"
  expected_name=$(printf '%06d.json' "$generation")
  [ "$name" = "$expected_name" ] || fail "$name does not match generation $generation"

  if [ -n "$PREVIOUS_FILE" ]; then
    [ "$generation" -eq $((PREVIOUS_GENERATION + 1)) ] || fail "gap between generations $PREVIOUS_GENERATION and $generation"
    [ "$previous_generation" -eq "$PREVIOUS_GENERATION" ] || fail "$name previous_generation does not match prior record"
    [ "$previous_state_sha256" = "$LAST_STATE_SHA256" ] || fail "$name previous_state_sha256 does not match prior state_sha256"

    expected_history_sha256=$(sha256sum "$PREVIOUS_FILE" | awk '{print $1}')
    actual_history_sha256=$(jq -er '.previous_history_sha256 | select(type == "string" and test("^[0-9a-f]{64}$"))' "$file")
    [ "$actual_history_sha256" = "$expected_history_sha256" ] || fail "$name previous_history_sha256 does not match prior record bytes"
  else
    # The first retained journal record is an explicit trust boundary. We can
    # validate its own transition, but cannot reconstruct pre-journal bytes.
    first_previous_history=$(jq -r '.previous_history_sha256 // empty' "$file")
    [ -z "$first_previous_history" ] || fail "$name first retained record unexpectedly claims an earlier history hash"
  fi

  record_authority_sha256=$(jq -r '.authority.sha256 // empty' "$file")
  record_authority_version=$(jq -r '.authority.policy_version // empty' "$file")

  if [ -n "$record_authority_sha256" ] || [ -n "$record_authority_version" ]; then
    [ -n "$record_authority_sha256" ] && [ -n "$record_authority_version" ] \
      || fail "$name has partial authority binding"
    [[ "$record_authority_sha256" =~ ^[0-9a-f]{64}$ ]] || fail "$name has malformed authority sha256"
    [[ "$record_authority_version" =~ ^[0-9]+$ ]] || fail "$name has malformed authority policy version"

    if [ "$AUTHORITY_BINDING_STARTED" -eq 0 ]; then
      AUTHORITY_BINDING_STARTED=1
      AUTHORITY_BINDING_GENERATION="$generation"
    fi

    [ "$record_authority_sha256" = "$CURRENT_AUTHORITY_SHA256" ] \
      || fail "$name authority sha256 does not match current policy bytes"
    [ "$record_authority_version" -eq "$CURRENT_AUTHORITY_VERSION" ] \
      || fail "$name authority policy version does not match current policy version"
  else
    [ "$AUTHORITY_BINDING_STARTED" -eq 0 ] \
      || fail "$name drops authority binding after generation $AUTHORITY_BINDING_GENERATION"
  fi

  PREVIOUS_FILE="$file"
  PREVIOUS_GENERATION="$generation"
  LAST_GENERATION="$generation"
  LAST_STATE_SHA256="$state_sha256"
done

[ "$LAST_GENERATION" -eq "$HEAD_GENERATION" ] || fail "head generation $HEAD_GENERATION != last lineage generation $LAST_GENERATION"
[ "$LAST_STATE_SHA256" = "$HEAD_SHA256" ] || fail "head state hash does not match last lineage state_sha256"

if [ "$AUTHORITY_BINDING_STARTED" -eq 1 ]; then
  echo "LINEAGE VERIFIED identity=$IDENTITY generations=${FILES[0]%.json}..$LAST_GENERATION head_sha256=$HEAD_SHA256 authority_bound_from=$AUTHORITY_BINDING_GENERATION authority_sha256=$CURRENT_AUTHORITY_SHA256"
else
  echo "LINEAGE VERIFIED identity=$IDENTITY generations=${FILES[0]%.json}..$LAST_GENERATION head_sha256=$HEAD_SHA256 authority_bound_from=not-yet-bootstrap"
fi
