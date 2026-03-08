# Phase 1: Foundation

Implement the following changes to the Skills-and-others repository. This phase creates the foundational configuration files and enhances the hook system.

## Current State

```
.claude/
  hooks/
    session-start.sh    # Minimal async SessionStart hook (remote-only)
  settings.json         # Only registers SessionStart
README.md
PLAN.md
```

## Target State After This Phase

```
.claude/
  hooks/
    session-start.sh    # ENHANCED: dependency detection, logging, state loading
    stop.sh             # NEW: track session activity
    pre-compact.sh      # NEW: save state before context compaction
  settings.json         # UPDATED: registers all hooks
CLAUDE.md               # NEW: project-level Claude config
.gitignore              # NEW
```

---

## Task 1.1: Create CLAUDE.md at project root

This is the most important file — Claude Code reads it automatically.

```markdown
# Skills-and-others

Claude Code configuration system for SGridworks projects. Provides reusable skills, hooks, agents, rules, commands, and contexts.

## Project Purpose

This repository is a modular Claude Code configuration system. It is NOT an application — it is a collection of configuration files, shell scripts, and markdown-based workflow definitions that enhance Claude Code sessions.

## Architecture

- `agents/` — Specialized subagent definitions (markdown files with role, tools, methodology)
- `skills/` — Reusable workflow definitions (each skill is a directory with SKILL.md)
- `commands/` — Slash command definitions (markdown prompts)
- `rules/` — Always-on guidelines organized by language
- `hooks/` — Shell scripts triggered by Claude Code lifecycle events
- `contexts/` — Dynamic system prompt modes (dev, review, research)
- `mcp-configs/` — MCP server configuration templates
- `memory-persistence/` — Session state save/load scripts
- `examples/` — Example CLAUDE.md files for real projects

## Critical Rules

- All shell scripts MUST use `set -euo pipefail`
- All shell scripts MUST be executable (`chmod +x`)
- Hook scripts MUST output valid JSON when producing structured output
- Skills are markdown — no executable code in skill definitions
- Agent definitions restrict tool access via frontmatter
- Keep files under 400 lines; split if larger
- No hardcoded secrets or credentials anywhere
- Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`

## Testing

```bash
bash tests/test-hooks.sh       # Validate hooks
bash tests/test-configs.sh     # Validate JSON configs
shellcheck .claude/hooks/*.sh  # Lint shell scripts
```

## File Conventions

- Hook scripts: Bash, `.sh` extension, executable
- Skills: `skills/<name>/SKILL.md`
- Agents: `agents/<name>.md`
- Commands: `commands/<name>.md`
- Rules: `rules/<category>/<name>.md`
- Contexts: `contexts/<mode>.md`
```

---

## Task 1.2: Create .gitignore

```gitignore
# Dependencies
node_modules/
__pycache__/
*.pyc
.venv/
venv/

# Environment
.env
.env.local
.env.*.local

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Build artifacts
dist/
build/
*.o
*.so

# Session state (managed by hooks, not committed)
.claude/memory/
.claude/state/
*.tmp

# Logs
*.log
```

---

## Task 1.3: Replace session-start.sh with enhanced version

Replace the existing `.claude/hooks/session-start.sh`:

```bash
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
```

---

## Task 1.4: Create .claude/hooks/stop.sh

```bash
#!/bin/bash
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="${PROJECT_DIR}/.claude/memory"

# Lightweight — runs after every Claude response
mkdir -p "$MEMORY_DIR"

# Track session activity
ACTIVITY_FILE="${MEMORY_DIR}/session-activity.log"
echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] response completed" >> "$ACTIVITY_FILE" 2>/dev/null || true
```

---

## Task 1.5: Create .claude/hooks/pre-compact.sh

```bash
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
```

---

## Task 1.6: Update .claude/settings.json

Replace with all hook registrations:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-start.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/stop.sh"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/pre-compact.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Task 1.7: Make all hooks executable

```bash
chmod +x .claude/hooks/*.sh
```

---

## Commit

```bash
git add CLAUDE.md .gitignore .claude/hooks/ .claude/settings.json
git commit -m "feat: add foundation — CLAUDE.md, .gitignore, enhanced hooks with lifecycle coverage"
```
