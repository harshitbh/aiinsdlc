#!/bin/bash
# $1 = start or stop
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG="submission/ai-logs/raw-session.jsonl"
mkdir -p submission/ai-logs

SESSION="${COPILOT_SESSION_ID:-unknown}"
AGENT="${COPILOT_SUBAGENT_NAME:-unknown}"

printf '{"ts":"%s","event":"subagent_%s","session":"%s","agent":"%s"}\n' \
  "$TS" "$1" "$SESSION" "$AGENT" >> "$LOG"