#!/bin/bash
set -euo pipefail

# PreToolUse guard hook for Bash tool
# Blocks dangerous commands before execution
# Exit code 2 = block the tool call

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

if [ -z "$COMMAND" ]; then
  exit 0
fi

BLOCKED_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \$HOME"
  "git push --force"
  "git push -f"
  "git reset --hard"
  "DROP TABLE"
  "DROP DATABASE"
  "TRUNCATE TABLE"
  ":(){ :|:& };:"
  "mkfs"
  "> /dev/sda"
  "dd if="
)

COMMAND_LOWER=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]')

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  pattern_lower=$(echo "$pattern" | tr '[:upper:]' '[:lower:]')
  if echo "$COMMAND_LOWER" | grep -qF "$pattern_lower"; then
    echo '{"decision": "block", "reason": "Blocked destructive command matching pattern: '"$pattern"'"}'
    exit 2
  fi
done

exit 0
