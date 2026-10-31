#!/bin/bash
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG="submission/ai-logs/raw-session.jsonl"
mkdir -p submission/ai-logs

TOOL="${COPILOT_TOOL_NAME:-unknown}"
SESSION="${COPILOT_SESSION_ID:-unknown}"

printf '{"ts":"%s","event":"tool_use","session":"%s","tool":"%s"}\n' \
  "$TS" "$SESSION" "$TOOL" >> "$LOG"