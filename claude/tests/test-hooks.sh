#!/bin/bash
set -uo pipefail

PASS=0
FAIL=0

assert() {
  local desc="$1"
  local result="$2"
  if [ "$result" = "0" ]; then
    echo "  PASS: $desc"
    ((PASS++)) || true
  else
    echo "  FAIL: $desc"
    ((FAIL++)) || true
  fi
}

echo "=== Hook Tests ==="

# Test: All hook scripts exist
for hook in session-start stop pre-compact guard-bash; do
  if [ -f ".claude/hooks/${hook}.sh" ]; then
    assert "Hook ${hook}.sh exists" 0
  else
    assert "Hook ${hook}.sh exists" 1
  fi
done

# Test: All hook scripts are executable
for hook in .claude/hooks/*.sh; do
  if [ -x "$hook" ]; then
    assert "$(basename "$hook") is executable" 0
  else
    assert "$(basename "$hook") is executable" 1
  fi
done

# Test: All hook scripts use set -euo pipefail
for hook in .claude/hooks/*.sh; do
  if grep -q "set -euo pipefail" "$hook" 2>/dev/null || grep -q "set -uo pipefail" "$hook" 2>/dev/null; then
    assert "$(basename "$hook") uses strict mode" 0
  else
    assert "$(basename "$hook") uses strict mode" 1
  fi
done

# Test: settings.json is valid JSON
if python3 -m json.tool .claude/settings.json > /dev/null 2>&1; then
  assert "settings.json is valid JSON" 0
else
  assert "settings.json is valid JSON" 1
fi

# Test: settings.json references existing hooks
for hook_path in $(grep -oP '\$CLAUDE_PROJECT_DIR/[^"]+' .claude/settings.json); do
  resolved="${hook_path/\$CLAUDE_PROJECT_DIR/.}"
  if [ -f "$resolved" ]; then
    assert "Referenced hook exists: $resolved" 0
  else
    assert "Referenced hook exists: $resolved" 1
  fi
done

# Test: PreToolUse hook is configured
if grep -q "PreToolUse" .claude/settings.json 2>/dev/null; then
  assert "PreToolUse hook is configured" 0
else
  assert "PreToolUse hook is configured" 1
fi

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ] || exit 1
