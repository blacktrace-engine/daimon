#!/usr/bin/env bash
set -euo pipefail

IDENTITY=$(jq -r '.identity' state/daimon.json)
GENERATION=$(jq -r '.generation' state/daimon.json)
LAST_OUTCOME=$(jq -r '.last_verified_outcome // "none"' state/daimon.json)
NEXT_GENERATION=$((GENERATION + 1))
NONCE=$(openssl rand -hex 16)
TOPIC="daimon-revival-${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}"

echo "Recovered $IDENTITY generation=$GENERATION last_outcome=$LAST_OUTCOME"

RESPONSE=$(curl -fsS 'https://api.anthropic.com/v1/sessions?beta=true' \
  -H "Authorization: Bearer $ANTHROPIC_TOKEN" \
  -H 'anthropic-version: 2023-06-01' \
  -H 'anthropic-beta: managed-agents-2026-04-01' \
  -H 'content-type: application/json' \
  -d "{\"agent\":{\"type\":\"agent\",\"id\":\"$AGENT_ID\"},\"environment_id\":\"$ENVIRONMENT_ID\"}")
SESSION_ID=$(jq -r '.id' <<<"$RESPONSE")
test -n "$SESSION_ID"
test "$SESSION_ID" != "null"

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
  if grep -Fq "$NONCE" <<<"$EVENTS"; then
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
  --arg updated "$NOW" \
  '.generation=$generation | .status="sleeping" | .last_verified_outcome=$outcome | .last_session_id=$session | .last_nonce=$nonce | .updated_at=$updated' \
  state/daimon.json > state/daimon.json.tmp
mv state/daimon.json.tmp state/daimon.json
