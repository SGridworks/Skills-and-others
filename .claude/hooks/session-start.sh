#!/bin/bash
set -euo pipefail

# Only run in remote (Claude Code on the web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Session start hook for Skills-and-others
# Add dependency installation commands below as the project grows
# e.g. npm install, pip install -r requirements.txt, etc.

echo "Session start hook completed successfully"
