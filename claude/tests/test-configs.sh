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
for d in claude/skills/*/; do
  if [ -f "${d}SKILL.md" ]; then
    assert "SKILL.md exists in $d" 0
  else
    assert "SKILL.md exists in $d" 1
  fi
done

# Test: All skills have frontmatter
for d in claude/skills/*/; do
  if [ -f "${d}SKILL.md" ] && head -1 "${d}SKILL.md" | grep -q "^---"; then
    assert "$(basename "$d") skill has frontmatter" 0
  else
    assert "$(basename "$d") skill has frontmatter" 1
  fi
done

# Test: All skill descriptions include trigger phrases ("Use when")
for d in claude/skills/*/; do
  if [ -f "${d}SKILL.md" ] && grep -q "Use when" "${d}SKILL.md" 2>/dev/null; then
    assert "$(basename "$d") skill has trigger phrases" 0
  else
    assert "$(basename "$d") skill has trigger phrases" 1
  fi
done

# Test: All skill descriptions include negative triggers ("Do NOT use")
for d in claude/skills/*/; do
  if [ -f "${d}SKILL.md" ] && grep -q "Do NOT use" "${d}SKILL.md" 2>/dev/null; then
    assert "$(basename "$d") skill has negative triggers" 0
  else
    assert "$(basename "$d") skill has negative triggers" 1
  fi
done

# Test: All skills have metadata section
for d in claude/skills/*/; do
  if [ -f "${d}SKILL.md" ] && grep -q "^metadata:" "${d}SKILL.md" 2>/dev/null; then
    assert "$(basename "$d") skill has metadata" 0
  else
    assert "$(basename "$d") skill has metadata" 1
  fi
done

# Test: All skills have Examples section
for d in claude/skills/*/; do
  if [ -f "${d}SKILL.md" ] && grep -q "^## Examples" "${d}SKILL.md" 2>/dev/null; then
    assert "$(basename "$d") skill has Examples section" 0
  else
    assert "$(basename "$d") skill has Examples section" 1
  fi
done

# Test: All skills have Troubleshooting section
for d in claude/skills/*/; do
  if [ -f "${d}SKILL.md" ] && grep -q "^## Troubleshooting" "${d}SKILL.md" 2>/dev/null; then
    assert "$(basename "$d") skill has Troubleshooting section" 0
  else
    assert "$(basename "$d") skill has Troubleshooting section" 1
  fi
done

# Test: All skills have Rules section
for d in claude/skills/*/; do
  if [ -f "${d}SKILL.md" ] && grep -q "^## Rules" "${d}SKILL.md" 2>/dev/null; then
    assert "$(basename "$d") skill has Rules section" 0
  else
    assert "$(basename "$d") skill has Rules section" 1
  fi
done

# Test: No skill names contain "claude" or "anthropic"
for d in claude/skills/*/; do
  skill_name=$(basename "$d")
  if echo "$skill_name" | grep -qiE "claude|anthropic"; then
    assert "$skill_name does not use reserved name" 1
  else
    assert "$skill_name does not use reserved name" 0
  fi
done

# Test: All skill folder names are kebab-case
for d in claude/skills/*/; do
  skill_name=$(basename "$d")
  if echo "$skill_name" | grep -qP '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'; then
    assert "$skill_name is kebab-case" 0
  else
    assert "$skill_name is kebab-case" 1
  fi
done

# Test: No README.md inside skill folders
for d in claude/skills/*/; do
  if [ -f "${d}README.md" ]; then
    assert "$(basename "$d") has no README.md inside skill folder" 1
  else
    assert "$(basename "$d") has no README.md inside skill folder" 0
  fi
done

# Test: All agents have frontmatter
for f in claude/agents/*.md; do
  if head -1 "$f" | grep -q "^---"; then
    assert "$(basename "$f") has frontmatter" 0
  else
    assert "$(basename "$f") has frontmatter" 1
  fi
done

# Test: All agents have model field
for f in claude/agents/*.md; do
  if grep -q "^model:" "$f" 2>/dev/null; then
    assert "$(basename "$f") has model field" 0
  else
    assert "$(basename "$f") has model field" 1
  fi
done

# Test: All agents have maxTurns field
for f in claude/agents/*.md; do
  if grep -q "^maxTurns:" "$f" 2>/dev/null; then
    assert "$(basename "$f") has maxTurns field" 0
  else
    assert "$(basename "$f") has maxTurns field" 1
  fi
done

# Test: Context files exist
for ctx in dev review research; do
  if [ -f "claude/contexts/${ctx}.md" ]; then
    assert "Context ${ctx}.md exists" 0
  else
    assert "Context ${ctx}.md exists" 1
  fi
done

# Test: Golang rules exist
if [ -f "claude/rules/golang/golang.md" ]; then
  assert "Golang rules exist" 0
else
  assert "Golang rules exist" 1
fi

# Test: OpenClaw directory structure exists
if [ -d "openclaw" ]; then
  assert "openclaw/ directory exists" 0
else
  assert "openclaw/ directory exists" 1
fi

# Test: README.md exists and is non-empty
if [ -s "README.md" ]; then
  assert "README.md exists and is non-empty" 0
else
  assert "README.md exists and is non-empty" 1
fi

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ] || exit 1
