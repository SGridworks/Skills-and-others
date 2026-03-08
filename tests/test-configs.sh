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

echo "=== Configuration Tests ==="

# Test: All JSON files are valid
for f in $(find . -name "*.json" -not -path "./.git/*"); do
  if python3 -m json.tool "$f" > /dev/null 2>&1; then
    assert "Valid JSON: $f" 0
  else
    assert "Valid JSON: $f" 1
  fi
done

# Test: CLAUDE.md exists
if [ -f "CLAUDE.md" ]; then
  assert "CLAUDE.md exists" 0
else
  assert "CLAUDE.md exists" 1
fi

# Test: .gitignore exists
if [ -f ".gitignore" ]; then
  assert ".gitignore exists" 0
else
  assert ".gitignore exists" 1
fi

# Test: All skills have SKILL.md
for d in skills/*/; do
  if [ -f "${d}SKILL.md" ]; then
    assert "SKILL.md exists in $d" 0
  else
    assert "SKILL.md exists in $d" 1
  fi
done

# Test: All commands have frontmatter
for f in commands/*.md; do
  if head -1 "$f" | grep -q "^---"; then
    assert "$(basename "$f") has frontmatter" 0
  else
    assert "$(basename "$f") has frontmatter" 1
  fi
done

# Test: README.md exists and is non-empty
if [ -s "README.md" ]; then
  assert "README.md exists and is non-empty" 0
else
  assert "README.md exists and is non-empty" 1
fi

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ] || exit 1
