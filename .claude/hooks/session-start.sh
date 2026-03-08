#!/bin/bash
set -euo pipefail

# Only run in remote (Claude Code on the web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Configurable async timeout (default: 5 minutes)
ASYNC_TIMEOUT="${ECC_ASYNC_TIMEOUT:-300000}"
echo "{\"async\": true, \"asyncTimeout\": ${ASYNC_TIMEOUT}}"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOG_FILE="${PROJECT_DIR}/.claude/session-start.log"

log() {
  echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] $*" >> "$LOG_FILE" 2>/dev/null || true
}

log "Session start hook triggered"

# Detect and install dependencies
if [ -f "${PROJECT_DIR}/package.json" ]; then
  log "Detected Node.js project, running npm install"
  cd "$PROJECT_DIR" && npm install --prefer-offline --no-audit 2>>"$LOG_FILE" || log "npm install failed (non-fatal)"
elif [ -f "${PROJECT_DIR}/requirements.txt" ]; then
  log "Detected Python project, installing requirements"
  pip install -r "${PROJECT_DIR}/requirements.txt" -q 2>>"$LOG_FILE" || log "pip install failed (non-fatal)"
elif [ -f "${PROJECT_DIR}/pyproject.toml" ]; then
  log "Detected Python project (pyproject.toml)"
  pip install -e "${PROJECT_DIR}" -q 2>>"$LOG_FILE" || log "pip install failed (non-fatal)"
elif [ -f "${PROJECT_DIR}/go.mod" ]; then
  log "Detected Go project"
  cd "$PROJECT_DIR" && go mod download 2>>"$LOG_FILE" || log "go mod download failed (non-fatal)"
fi

# Load persisted memory state if available
MEMORY_DIR="${PROJECT_DIR}/.claude/memory"
if [ -d "$MEMORY_DIR" ] && [ -f "${MEMORY_DIR}/session-state.json" ]; then
  log "Loaded persisted session state"
fi

log "Session start hook completed"
echo "Session start hook completed successfully"
