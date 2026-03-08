# Phase 5: Examples, Installer, and Documentation

Create example CLAUDE.md files for real projects, a cross-platform installer, and updated documentation. This is the final phase.

## Target State After This Phase

```
examples/
  saas-nextjs-CLAUDE.md
  go-microservice-CLAUDE.md
  django-api-CLAUDE.md
install.sh
README.md                  # Updated to reflect full structure
```

---

## Task 5.1: Create Example CLAUDE.md Files

### examples/saas-nextjs-CLAUDE.md

```markdown
# SaaS Application (Next.js + Supabase + Stripe)

## Stack
- Next.js 15 (App Router)
- Supabase (Auth, Database, Storage)
- Stripe (Payments)
- Tailwind CSS + shadcn/ui
- Playwright (E2E tests)

## Critical Rules
- ALWAYS use `getUser()`, NEVER `getSession()` for auth checks
- ALWAYS use `createServerClient` in Server Components, `createBrowserClient` in Client Components
- ALL database tables MUST have Row Level Security (RLS) policies
- ALL API inputs validated with Zod
- NEVER expose Stripe secret key to client code
- Webhook handlers MUST verify Stripe signatures

## Project Structure

app/
  (auth)/          # Auth routes (login, signup, callback)
  (dashboard)/     # Protected routes
  api/             # API routes
    webhooks/      # Stripe webhooks
components/        # Shared UI components
lib/
  supabase/        # Supabase client factories
  stripe/          # Stripe utilities
  validations/     # Zod schemas

## Commands

- `npm run dev` — Development server
- `npm run build` — Production build
- `npm test` — Unit tests
- `npx playwright test` — E2E tests
- `npm run lint` — ESLint
- `npx tsc --noEmit` — Type check
```

### examples/go-microservice-CLAUDE.md

```markdown
# Go Microservice (gRPC + PostgreSQL)

## Stack
- Go 1.22+
- gRPC + Protocol Buffers
- PostgreSQL + sqlc
- Wire (dependency injection)
- Docker + docker-compose

## Critical Rules
- Context as first parameter: `func Foo(ctx context.Context, ...)`
- Error wrapping with `fmt.Errorf("operation: %w", err)` — never `%v` for errors
- No `init()` functions — use explicit initialization
- No global mutable state
- Table-driven tests for all logic
- Race detection in CI: `go test -race ./...`
- Always close database rows: `defer rows.Close()`

## Project Structure

cmd/
  server/            # Main entry point
internal/
  domain/            # Business logic (no external dependencies)
  handler/           # gRPC handlers
  repository/        # Database access (sqlc generated)
  service/           # Application services
proto/               # Protocol Buffer definitions
migrations/          # SQL migrations

## Commands

- `go build ./...` — Build
- `go test ./...` — Unit tests
- `go test -race ./...` — Race detection
- `golangci-lint run` — Lint
- `sqlc generate` — Regenerate DB code
- `buf generate` — Regenerate gRPC code
- `docker-compose up -d` — Start dependencies
```

### examples/django-api-CLAUDE.md

```markdown
# Django REST API (DRF + Celery)

## Stack
- Python 3.12+
- Django 5.x + Django REST Framework
- Celery + Redis (async tasks)
- PostgreSQL
- pytest + factory_boy

## Critical Rules
- ALL views MUST have explicit permission classes
- ALL querysets MUST be filtered by tenant/user — no unscoped queries
- Use `select_related()` / `prefetch_related()` to prevent N+1 queries
- Serializer validation for ALL input — never trust `request.data` directly
- Celery tasks MUST be idempotent
- Database migrations reviewed before merging

## Project Structure

config/              # Django settings, URLs, WSGI/ASGI
apps/
  users/             # User management
  core/              # Shared models, mixins, utils
  api/               # API versioning (v1/, v2/)
tasks/               # Celery task definitions
tests/
  factories/         # factory_boy factories
  fixtures/          # Test data

## Commands

- `python manage.py runserver` — Dev server
- `pytest` — Run tests
- `pytest --cov --cov-report=term` — Coverage
- `ruff check .` — Lint
- `ruff format .` — Format
- `mypy .` — Type check
- `python manage.py migrate` — Apply migrations
- `celery -A config worker -l info` — Start Celery worker
```

---

## Task 5.2: Create install.sh

```bash
#!/bin/bash
set -euo pipefail

# Skills-and-others Installer
# Usage: ./install.sh [--target claude|cursor] [language...]
# Example: ./install.sh typescript python
# Example: ./install.sh --target cursor typescript

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="claude"
LANGUAGES=()

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 [--target claude|cursor] [language...]"
      echo ""
      echo "Languages: typescript, python, golang"
      echo "Targets: claude (default), cursor"
      echo ""
      echo "Examples:"
      echo "  $0 typescript           # Install TypeScript rules for Claude Code"
      echo "  $0 --target cursor python  # Install Python rules for Cursor"
      echo "  $0 typescript python    # Install both"
      exit 0
      ;;
    *)
      # Validate language (prevent path traversal)
      if [[ "$1" =~ ^[a-zA-Z]+$ ]]; then
        LANGUAGES+=("$1")
      else
        echo "ERROR: Invalid language: $1"
        exit 1
      fi
      shift
      ;;
  esac
done

# Determine destination
case "$TARGET" in
  claude)
    RULES_DIR="$HOME/.claude/rules"
    ;;
  cursor)
    RULES_DIR="./.cursor/rules"
    ;;
  *)
    echo "ERROR: Unknown target: $TARGET (use 'claude' or 'cursor')"
    exit 1
    ;;
esac

echo "Installing Skills-and-others configuration..."
echo "Target: $TARGET"
echo "Rules directory: $RULES_DIR"

# Install common rules
mkdir -p "$RULES_DIR"
if [ -d "${SCRIPT_DIR}/rules/common" ]; then
  echo "Installing common rules..."
  cp "${SCRIPT_DIR}/rules/common/"*.md "$RULES_DIR/"
  echo "  Installed: $(ls "${SCRIPT_DIR}/rules/common/"*.md | wc -l | tr -d ' ') common rules"
fi

# Install language-specific rules
for lang in "${LANGUAGES[@]}"; do
  if [ -d "${SCRIPT_DIR}/rules/${lang}" ]; then
    echo "Installing ${lang} rules..."
    cp "${SCRIPT_DIR}/rules/${lang}/"*.md "$RULES_DIR/"
    echo "  Installed: $(ls "${SCRIPT_DIR}/rules/${lang}/"*.md | wc -l | tr -d ' ') ${lang} rules"
  else
    echo "WARNING: No rules found for language: ${lang}"
  fi
done

# Install hooks (Claude target only)
if [ "$TARGET" = "claude" ]; then
  HOOKS_DIR="$HOME/.claude/hooks"
  if [ -d "${SCRIPT_DIR}/.claude/hooks" ]; then
    echo "Installing hooks..."
    mkdir -p "$HOOKS_DIR"
    cp "${SCRIPT_DIR}/.claude/hooks/"*.sh "$HOOKS_DIR/"
    chmod +x "$HOOKS_DIR/"*.sh
    echo "  Installed: $(ls "${SCRIPT_DIR}/.claude/hooks/"*.sh | wc -l | tr -d ' ') hooks"
  fi
fi

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Review installed rules in: $RULES_DIR"
if [ "$TARGET" = "claude" ]; then
  echo "  2. Copy relevant MCP configs from mcp-configs/mcp-servers.json to your project"
  echo "  3. Create a project-specific CLAUDE.md (see examples/ for templates)"
fi
```

Make executable: `chmod +x install.sh`

---

## Task 5.3: Update README.md

Replace with:

```markdown
# Skills-and-others

Claude Code configuration system for SGridworks projects. Provides reusable skills, hooks, agents, rules, commands, and contexts.

## Quick Start

```bash
git clone <repo-url>
cd Skills-and-others
./install.sh typescript  # Install rules for your language

# For Cursor users
./install.sh --target cursor typescript
```

## Structure

```
agents/              # 5 specialized subagent definitions
skills/              # 6 workflow skills (code-review, tdd, plan, verify, build-fix, learning)
commands/            # 6 slash commands
rules/               # Coding guidelines (common + language-specific)
hooks/               # Claude Code lifecycle hooks
contexts/            # Dynamic system prompt modes (dev, review, research)
mcp-configs/         # MCP server configuration templates
memory-persistence/  # Session state save/load scripts
examples/            # Example CLAUDE.md files for real projects
tests/               # Validation test suite
```

## Skills

| Skill | Purpose |
|-------|---------|
| code-review | Structured review with severity-ranked findings |
| tdd | Test-driven development workflow |
| plan | Phased implementation planning |
| verify | Run tests, lint, typecheck, build |
| build-fix | Diagnose and fix build errors |
| continuous-learning | Extract reusable patterns from sessions |

## Agents

| Agent | Purpose |
|-------|---------|
| planner | Feature implementation planning |
| code-reviewer | Quality and security review |
| tdd-guide | Test-driven development guidance |
| security-reviewer | Vulnerability identification |
| build-resolver | Build error resolution |

## Commands

| Command | Description |
|---------|-------------|
| `/plan "desc"` | Plan feature implementation |
| `/tdd` | Start TDD workflow |
| `/code-review` | Run code review |
| `/verify` | Run verification checks |
| `/build-fix` | Fix build errors |
| `/learn` | Extract session patterns |

## Context Modes

Use with `claude --system-prompt "$(cat contexts/dev.md)"`:

- **dev** — Code-first, explain after
- **review** — Analyze before suggesting, severity-ranked findings
- **research** — Understand before acting, evidence-based

## Hooks

| Event | Script | Purpose |
|-------|--------|---------|
| SessionStart | session-start.sh | Dependency install, state restoration |
| Stop | stop.sh | Track session activity |
| PreCompact | pre-compact.sh | Save state before context compaction |

## Examples

See `examples/` for complete CLAUDE.md templates:
- `saas-nextjs-CLAUDE.md` — Next.js + Supabase + Stripe
- `go-microservice-CLAUDE.md` — Go + gRPC + PostgreSQL
- `django-api-CLAUDE.md` — Django REST + Celery

## Testing

```bash
bash tests/test-hooks.sh       # Validate hooks
bash tests/test-configs.sh     # Validate configs
shellcheck .claude/hooks/*.sh  # Lint shell scripts
```

## Installation

```bash
./install.sh --help            # Show usage
./install.sh typescript        # Install TS rules for Claude Code
./install.sh --target cursor python  # Install Python rules for Cursor
./install.sh typescript python golang  # Install multiple languages
```
```

---

## Commit

```bash
git add examples/ install.sh README.md
git commit -m "feat: add examples, installer, and updated documentation"
```

---

## Final Verification

After all 5 phases, run:

```bash
chmod +x .claude/hooks/*.sh memory-persistence/*.sh install.sh tests/*.sh
bash tests/test-hooks.sh
bash tests/test-configs.sh
```

All tests should pass. The repo is now a complete Claude Code configuration system.
