#!/bin/bash
# Fires on every userPromptSubmitted — logs the prompt automatically
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG="submission/ai-logs/raw-session.jsonl"
mkdir -p submission/ai-logs

# Hook receives context via env vars from Copilot
PROMPT="${COPILOT_PROMPT:-unknown}"
SESSION="${COPILOT_SESSION_ID:-unknown}"
TASK="${COPILOT_TASK:-untagged}"

printf '{"ts":"%s","event":"prompt","session":"%s","task":"%s","prompt":%s}\n' \
  "$TS" "$SESSION" "$TASK" "$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')" \
  >> "$LOG"