#!/bin/bash
set -euo pipefail

# Load persisted session state
# Called by session-start hook

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="${PROJECT_DIR}/.claude/memory"
STATE_FILE="${MEMORY_DIR}/session-state.json"

if [ ! -f "$STATE_FILE" ]; then
  echo "No persisted state found."
  exit 0
fi

echo "Previous session state:"
cat "$STATE_FILE"
