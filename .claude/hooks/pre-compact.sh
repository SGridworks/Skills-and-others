#!/bin/bash
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="${PROJECT_DIR}/.claude/memory"
COMPACT_FILE="${MEMORY_DIR}/pre-compact-state.md"

log() {
  echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] $*" >> "${PROJECT_DIR}/.claude/pre-compact.log" 2>/dev/null || true
}

log "Pre-compact hook triggered — saving state before context compaction"

mkdir -p "$MEMORY_DIR"

# Save what we know before compaction wipes context
{
  echo "# Pre-Compaction State Snapshot"
  echo "Saved at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo ""

  if command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null; then
    echo "## Git State"
    echo "- Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
    echo "- Last commit: $(git log --oneline -1 2>/dev/null || echo 'none')"
    echo "- Uncommitted files: $(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
    echo ""

    CHANGED=$(git diff --name-only 2>/dev/null || true)
    if [ -n "$CHANGED" ]; then
      echo "## Modified Files"
      echo '```'
      echo "$CHANGED"
      echo '```'
      echo ""
    fi
  fi
} > "$COMPACT_FILE"

log "Pre-compact state saved to ${COMPACT_FILE}"
