#!/bin/bash
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG="submission/ai-logs/raw-session.jsonl"
mkdir -p submission/ai-logs

SESSION="${COPILOT_SESSION_ID:-unknown}"
MSG="${COPILOT_NOTIFICATION_MESSAGE:-unknown}"

printf '{"ts":"%s","event":"notification","session":"%s","message":%s}\n' \
  "$TS" "$SESSION" "$(echo "$MSG" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')" \
  >> "$LOG"