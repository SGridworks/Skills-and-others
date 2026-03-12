#!/bin/bash
set -euo pipefail

# Auto-format Python files after Write/Edit tool use.
# Reads the modified file path from CLAUDE_TOOL_INPUT (JSON).

if ! command -v jq &>/dev/null; then
  exit 0
fi

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Only format Python files
case "$FILE_PATH" in
  *.py)
    if command -v ruff &>/dev/null; then
      ruff format --quiet "$FILE_PATH" 2>/dev/null || true
      ruff check --fix --quiet "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
esac

exit 0
