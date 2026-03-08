# Phase 3: Infrastructure

Implement MCP configs, memory persistence, CI/CD, and tests. This phase builds on Phases 1-2.

## Target State After This Phase

```
mcp-configs/
  mcp-servers.json        # MCP server templates
memory-persistence/
  save-state.sh           # Reusable state save script
  load-state.sh           # Reusable state load script
tests/
  test-hooks.sh           # Hook validation tests
  test-configs.sh         # Config validation tests
.github/
  workflows/
    validate.yml          # CI validation workflow
```

---

## Task 3.1: Create mcp-configs/mcp-servers.json

Template MCP server configurations. Users copy relevant entries to their project settings.

```json
{
  "_comment": "MCP server templates for SGridworks projects. Copy relevant entries to your project's .claude/settings.json under 'mcpServers'. Keep under 10 active per project.",
  "github": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-github"],
    "env": {
      "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
    }
  },
  "memory": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-memory"]
  },
  "filesystem": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-filesystem", "${PROJECT_DIR}"]
  },
  "sequential-thinking": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
  },
  "supabase": {
    "command": "npx",
    "args": ["-y", "@supabase/mcp-server-supabase@latest", "--access-token", "${SUPABASE_ACCESS_TOKEN}"]
  },
  "vercel": {
    "type": "url",
    "url": "https://mcp.vercel.com/sse"
  }
}
```

---

## Task 3.2: Create memory-persistence/save-state.sh

```bash
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
```

Make executable: `chmod +x memory-persistence/save-state.sh`

---

## Task 3.3: Create memory-persistence/load-state.sh

```bash
#!/bin/bash
set -euo pipefail

# Load persisted session state
# Called by session-start hook

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="${PROJECT_DIR}/.claude/memory"
STATE_FILE="${MEMORY_DIR}/session-state.json"

if [ ! -f "$STATE_FILE" ]; then
  echo "No persisted state found."
  exit 0
fi

echo "Previous session state:"
cat "$STATE_FILE"
```

Make executable: `chmod +x memory-persistence/load-state.sh`

---

## Task 3.4: Create tests/test-hooks.sh

```bash
#!/bin/bash
set -euo pipefail

PASS=0
FAIL=0

assert() {
  local desc="$1"
  local result="$2"
  if [ "$result" = "0" ]; then
    echo "  PASS: $desc"
    ((PASS++))
  else
    echo "  FAIL: $desc"
    ((FAIL++))
  fi
}

echo "=== Hook Tests ==="

# Test: All hook scripts exist
for hook in session-start stop pre-compact; do
  [ -f ".claude/hooks/${hook}.sh" ]
  assert "Hook ${hook}.sh exists" $?
done

# Test: All hook scripts are executable
for hook in .claude/hooks/*.sh; do
  [ -x "$hook" ]
  assert "$(basename "$hook") is executable" $?
done

# Test: All hook scripts use set -euo pipefail
for hook in .claude/hooks/*.sh; do
  grep -q "set -euo pipefail" "$hook"
  assert "$(basename "$hook") uses strict mode" $?
done

# Test: settings.json is valid JSON
python3 -m json.tool .claude/settings.json > /dev/null 2>&1
assert "settings.json is valid JSON" $?

# Test: settings.json references existing hooks
for hook_path in $(grep -oP '\$CLAUDE_PROJECT_DIR/[^"]+' .claude/settings.json); do
  resolved="${hook_path/\$CLAUDE_PROJECT_DIR/.}"
  [ -f "$resolved" ]
  assert "Referenced hook exists: $resolved" $?
done

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ] || exit 1
```

Make executable: `chmod +x tests/test-hooks.sh`

---

## Task 3.5: Create tests/test-configs.sh

```bash
#!/bin/bash
set -euo pipefail

PASS=0
FAIL=0

assert() {
  local desc="$1"
  local result="$2"
  if [ "$result" = "0" ]; then
    echo "  PASS: $desc"
    ((PASS++))
  else
    echo "  FAIL: $desc"
    ((FAIL++))
  fi
}

echo "=== Configuration Tests ==="

# Test: All JSON files are valid
for f in $(find . -name "*.json" -not -path "./.git/*"); do
  python3 -m json.tool "$f" > /dev/null 2>&1
  assert "Valid JSON: $f" $?
done

# Test: CLAUDE.md exists
[ -f "CLAUDE.md" ]
assert "CLAUDE.md exists" $?

# Test: .gitignore exists
[ -f ".gitignore" ]
assert ".gitignore exists" $?

# Test: All skills have SKILL.md
for d in skills/*/; do
  [ -f "${d}SKILL.md" ]
  assert "SKILL.md exists in $d" $?
done

# Test: All commands have frontmatter
for f in commands/*.md; do
  head -1 "$f" | grep -q "^---"
  assert "$(basename "$f") has frontmatter" $?
done

# Test: README.md exists and is non-empty
[ -s "README.md" ]
assert "README.md exists and is non-empty" $?

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ] || exit 1
```

Make executable: `chmod +x tests/test-configs.sh`

---

## Task 3.6: Create .github/workflows/validate.yml

```yaml
name: Validate Configuration

on:
  push:
    branches: [master, main]
  pull_request:
    branches: [master, main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check shell scripts are executable
        run: |
          EXIT=0
          find .claude/hooks memory-persistence -name "*.sh" 2>/dev/null | while read f; do
            if [ ! -x "$f" ]; then
              echo "ERROR: $f is not executable"
              EXIT=1
            fi
          done
          exit $EXIT

      - name: Lint shell scripts with shellcheck
        uses: ludeeus/action-shellcheck@master
        with:
          scandir: '.claude/hooks'
          additional_files: 'memory-persistence/save-state.sh memory-persistence/load-state.sh'

      - name: Validate JSON files
        run: |
          for f in $(find . -name "*.json" -not -path "./.git/*"); do
            echo "Validating $f"
            python3 -m json.tool "$f" > /dev/null || { echo "INVALID JSON: $f"; exit 1; }
          done

      - name: Check SKILL.md files exist for all skills
        run: |
          for d in skills/*/; do
            if [ ! -f "${d}SKILL.md" ]; then
              echo "ERROR: Missing SKILL.md in $d"
              exit 1
            fi
          done

      - name: Check required files exist
        run: |
          for f in CLAUDE.md .gitignore .claude/settings.json; do
            if [ ! -f "$f" ]; then
              echo "ERROR: Missing required file: $f"
              exit 1
            fi
          done

      - name: Run test suite
        run: |
          bash tests/test-hooks.sh
          bash tests/test-configs.sh
```

---

## Commit

```bash
git add mcp-configs/ memory-persistence/ tests/ .github/
chmod +x memory-persistence/*.sh tests/*.sh
git commit -m "feat: add infrastructure — MCP configs, memory persistence, CI/CD, test suite"
```
