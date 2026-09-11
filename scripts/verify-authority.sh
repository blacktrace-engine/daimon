#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="${1:-state/daimon.json}"
AUTHORITY_FILE="${2:-state/authority.json}"

fail() {
  echo "AUTHORITY INVALID: $*" >&2
  exit 1
}

[ -f "$STATE_FILE" ] || fail "missing state: $STATE_FILE"
[ -f "$AUTHORITY_FILE" ] || fail "missing authority policy: $AUTHORITY_FILE"

STATE_IDENTITY=$(jq -er '.identity | select(type == "string" and length > 0)' "$STATE_FILE")
POLICY_IDENTITY=$(jq -er '.identity | select(type == "string" and length > 0)' "$AUTHORITY_FILE")
POLICY_VERSION=$(jq -er '.policy_version | select(type == "number" and floor == . and . >= 1)' "$AUTHORITY_FILE")
POLICY_STATUS=$(jq -er '.status | select(type == "string" and length > 0)' "$AUTHORITY_FILE")
MAX_STEP=$(jq -er '.max_generation_step | select(type == "number" and floor == . and . == 1)' "$AUTHORITY_FILE")
REQUIRE_LINEAGE=$(jq -er '.require_verified_lineage | select(type == "boolean")' "$AUTHORITY_FILE")
REPOSITORY=$(jq -er '.bindings.repository | select(type == "string" and length > 0)' "$AUTHORITY_FILE")
BRANCH=$(jq -er '.bindings.branch | select(type == "string" and length > 0)' "$AUTHORITY_FILE")
WORKER_PROVIDER=$(jq -er '.bindings.worker_provider | select(type == "string" and length > 0)' "$AUTHORITY_FILE")
VERIFICATION_PROVIDER=$(jq -er '.bindings.verification_provider | select(type == "string" and length > 0)' "$AUTHORITY_FILE")

[ "$STATE_IDENTITY" = "$POLICY_IDENTITY" ] || fail "policy identity $POLICY_IDENTITY != state identity $STATE_IDENTITY"
[ "$POLICY_STATUS" = "active" ] || fail "policy status is $POLICY_STATUS, not active"
[ "$MAX_STEP" -eq 1 ] || fail "generation step must be exactly 1"
[ "$REQUIRE_LINEAGE" = "true" ] || fail "verified lineage must be required"

for action in revive verify_external persist_state; do
  jq -e --arg action "$action" '.allowed_actions | type == "array" and index($action) != null' "$AUTHORITY_FILE" >/dev/null \
    || fail "required action not authorized: $action"
done

[ "$REPOSITORY" = "blacktrace-engine/daimon" ] || fail "unexpected repository binding: $REPOSITORY"
[ "$BRANCH" = "main" ] || fail "unexpected branch binding: $BRANCH"
[ "$WORKER_PROVIDER" = "api.anthropic.com" ] || fail "unexpected worker provider: $WORKER_PROVIDER"
[ "$VERIFICATION_PROVIDER" = "ntfy.sh" ] || fail "unexpected verification provider: $VERIFICATION_PROVIDER"

if [ -n "${GITHUB_REPOSITORY:-}" ]; then
  [ "$GITHUB_REPOSITORY" = "$REPOSITORY" ] || fail "runtime repository $GITHUB_REPOSITORY != authorized repository $REPOSITORY"
fi

if [ -n "${GITHUB_REF_NAME:-}" ]; then
  [ "$GITHUB_REF_NAME" = "$BRANCH" ] || fail "runtime branch $GITHUB_REF_NAME != authorized branch $BRANCH"
fi

echo "AUTHORITY VERIFIED identity=$STATE_IDENTITY policy_version=$POLICY_VERSION repository=$REPOSITORY branch=$BRANCH"
