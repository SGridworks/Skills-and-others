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
