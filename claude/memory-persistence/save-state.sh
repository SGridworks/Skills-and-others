#!/bin/bash
set -euo pipefail

# Save session state to persistent storage
# Called by hooks (stop, pre-compact)

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="${PROJECT_DIR}/.claude/memory"
STATE_FILE="${MEMORY_DIR}/session-state.json"

mkdir -p "$MEMORY_DIR"

TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
BRANCH="unknown"
LAST_COMMIT="none"
DIRTY=0

if command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
  LAST_COMMIT=$(git log --oneline -1 2>/dev/null || echo "none")
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
fi

cat > "$STATE_FILE" <<EOF
{
  "timestamp": "${TIMESTAMP}",
  "branch": "${BRANCH}",
  "last_commit": "${LAST_COMMIT}",
  "uncommitted_changes": ${DIRTY}
}
EOF
