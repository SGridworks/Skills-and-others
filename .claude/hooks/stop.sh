#!/bin/bash
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="${PROJECT_DIR}/.claude/memory"

# Lightweight — runs after every Claude response
mkdir -p "$MEMORY_DIR"

# Track session activity
ACTIVITY_FILE="${MEMORY_DIR}/session-activity.log"
echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] response completed" >> "$ACTIVITY_FILE" 2>/dev/null || true
