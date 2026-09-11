#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="state/daimon.json"
TMP_FILE="${STATE_FILE}.tmp"
HISTORY_DIR="state/history"
trap 'rm -f "$TMP_FILE"' EXIT

# Fail closed before creating a worker. Durable continuity is meaningful only if
# the controller can prove it recovered a valid state record.
jq -e '
  (.identity | type == "string" and length > 0) and
  (.generation | type == "number" and floor == . and . >= 0) and
  (.status | type == "string" and length > 0) and
  ((.last_verified_outcome // null) == null or (.last_verified_outcome | type == "string"))
' "$STATE_FILE" >/dev/null

IDENTITY=$(jq -r '.identity' "$STATE_FILE")
GENERATION=$(jq -r '.generation' "$STATE_FILE")
LAST_OUTCOME=$(jq -r '.last_verified_outcome // "none"' "$STATE_FILE")
NEXT_GENERATION=$((GENERATION + 1))
PREVIOUS_STATE_SHA256=$(sha256sum "$STATE_FILE" | awk '{print $1}')
PREVIOUS_HISTORY_FILE=$(printf '%s/%06d.json' "$HISTORY_DIR" "$GENERATION")
PREVIOUS_HISTORY_SHA256=""
if [ -f "$PREVIOUS_HISTORY_FILE" ]; then
  PREVIOUS_HISTORY_SHA256=$(sha256sum "$PREVIOUS_HISTORY_FILE" | awk '{print $1}')
fi
NONCE=$(openssl rand -hex 16)
TOPIC="daimon-revival-${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}"

echo "Recovered $IDENTITY generation=$GENERATION last_outcome=$LAST_OUTCOME"

RESPONSE=$(curl -fsS 'https://api.anthropic.com/v1/sessions?beta=true' \
  -H "Authorization: Bearer $ANTHROPIC_TOKEN" \
  -H 'anthropic-version: 2023-06-01' \
  -H 'anthropic-beta: managed-agents-2026-04-01' \
  -H 'content-type: application/json' \
  -d "{\"agent\":{\"type\":\"agent\",\"id\":\"$AGENT_ID\"},\"environment_id\":\"$ENVIRONMENT_ID\"}")
SESSION_ID=$(jq -er '.id | select(type == "string" and length > 0)' <<<"$RESPONSE")

MESSAGE=$(cat <<EOF
You are executing a continuation of Daimon identity $IDENTITY.
Durable state recovered outside this session:
generation: $GENERATION
last_verified_outcome: $LAST_OUTCOME

This is generation $NEXT_GENERATION.
POST the exact text $NONCE to https://ntfy.sh/$TOPIC using your available tools. Do not merely claim success. The external controller will verify independently. Once attempted, stop.
EOF
)
BODY=$(jq -n --arg message "$MESSAGE" '{events:[{type:"user.message",content:[{type:"text",text:$message}]}]}')
curl -fsS "https://api.anthropic.com/v1/sessions/$SESSION_ID/events?beta=true" \
  -H "Authorization: Bearer $ANTHROPIC_TOKEN" \
  -H 'anthropic-version: 2023-06-01' \
  -H 'anthropic-beta: managed-agents-2026-04-01' \
  -H 'content-type: application/json' \
  -d "$BODY" >/dev/null

VERIFIED=0
for attempt in $(seq 1 36); do
  EVENTS=$(curl -fsS "https://ntfy.sh/$TOPIC/json?poll=1&since=all" || true)
  # ntfy returns newline-delimited JSON. Verification requires an exact message
  # match, so metadata, echoed prompts, or partial strings cannot satisfy it.
  if jq -e -s --arg nonce "$NONCE" 'any(.[]; .event == "message" and .message == $nonce)' <<<"$EVENTS" >/dev/null 2>&1; then
    VERIFIED=1
    break
  fi
  sleep 5
done

test "$VERIFIED" = "1"
echo "DAIMON REVIVAL VERIFIED generation=$NEXT_GENERATION session=$SESSION_ID"

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
jq \
  --argjson generation "$NEXT_GENERATION" \
  --arg outcome "revival-generation-$NEXT_GENERATION-verified" \
  --arg session "$SESSION_ID" \
  --arg nonce "$NONCE" \
  --arg topic "$TOPIC" \
  --arg run_id "$GITHUB_RUN_ID" \
  --arg run_attempt "$GITHUB_RUN_ATTEMPT" \
  --arg updated "$NOW" \
  '.generation=$generation
   | .status="sleeping"
   | .last_verified_outcome=$outcome
   | .last_session_id=$session
   | .last_nonce=$nonce
   | .updated_at=$updated
   | .last_verification={method:"external_exact_message", topic:$topic, controller_run_id:$run_id, controller_run_attempt:$run_attempt, verified_at:$updated}' \
  "$STATE_FILE" > "$TMP_FILE"

# Validate the candidate record before replacing durable state, including the
# monotonic generation transition this run is permitted to make.
jq -e --arg identity "$IDENTITY" --argjson expected "$NEXT_GENERATION" '
  .identity == $identity and
  .generation == $expected and
  .status == "sleeping" and
  (.last_verified_outcome | type == "string" and length > 0) and
  (.last_session_id | type == "string" and length > 0) and
  (.last_nonce | type == "string" and length == 32) and
  (.last_verification.method == "external_exact_message") and
  (.last_verification.verified_at | type == "string" and length > 0)
' "$TMP_FILE" >/dev/null

mv "$TMP_FILE" "$STATE_FILE"
trap - EXIT

# Persist an immutable lineage record beside mutable head state. Each record
# hashes both the recovered state and the newly verified state. From the second
# journaled generation onward it also hashes the previous lineage entry, making
# retroactive edits detectable by walking the chain.
mkdir -p "$HISTORY_DIR"
HISTORY_FILE=$(printf '%s/%06d.json' "$HISTORY_DIR" "$NEXT_GENERATION")
test ! -e "$HISTORY_FILE"
NEW_STATE_SHA256=$(sha256sum "$STATE_FILE" | awk '{print $1}')

jq -n \
  --arg identity "$IDENTITY" \
  --argjson generation "$NEXT_GENERATION" \
  --argjson previous_generation "$GENERATION" \
  --arg previous_state_sha256 "$PREVIOUS_STATE_SHA256" \
  --arg state_sha256 "$NEW_STATE_SHA256" \
  --arg previous_history_sha256 "$PREVIOUS_HISTORY_SHA256" \
  --arg outcome "revival-generation-$NEXT_GENERATION-verified" \
  --arg method "external_exact_message" \
  --arg topic "$TOPIC" \
  --arg run_id "$GITHUB_RUN_ID" \
  --arg run_attempt "$GITHUB_RUN_ATTEMPT" \
  --arg verified_at "$NOW" \
  '{
    identity:$identity,
    generation:$generation,
    previous_generation:$previous_generation,
    previous_state_sha256:$previous_state_sha256,
    state_sha256:$state_sha256,
    previous_history_sha256:(if $previous_history_sha256 == "" then null else $previous_history_sha256 end),
    verified_outcome:$outcome,
    verification:{method:$method, topic:$topic, controller_run_id:$run_id, controller_run_attempt:$run_attempt, verified_at:$verified_at}
  }' > "$HISTORY_FILE"

jq -e \
  --arg identity "$IDENTITY" \
  --argjson generation "$NEXT_GENERATION" \
  --argjson previous_generation "$GENERATION" \
  --arg previous_state_sha256 "$PREVIOUS_STATE_SHA256" \
  --arg state_sha256 "$NEW_STATE_SHA256" '
    .identity == $identity and
    .generation == $generation and
    .previous_generation == $previous_generation and
    .previous_state_sha256 == $previous_state_sha256 and
    .state_sha256 == $state_sha256 and
    (.verification.method == "external_exact_message")
  ' "$HISTORY_FILE" >/dev/null

echo "LINEAGE RECORDED $HISTORY_FILE state_sha256=$NEW_STATE_SHA256"
