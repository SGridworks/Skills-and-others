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
- `user-CLAUDE.md` — User-level global config (`~/.claude/CLAUDE.md`)
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

---

## Setup Prompt — Full Installation via Claude Code

Copy and paste the prompt below into a new Claude Code session to have Claude set up everything automatically on any device. It walks through cloning the repo, running the installer, verifying the installation, and customizing the user-level config.

<details>
<summary><strong>Click to expand the full setup prompt</strong></summary>

~~~
I need you to set up the SGridworks Claude Code configuration system on this machine. Follow these steps exactly:

## Step 1: Clone and Install

Clone the Skills-and-others repo and run the installer:

```bash
cd ~
git clone https://github.com/SGridworks/Skills-and-others.git
cd Skills-and-others
./install.sh typescript python
```

This installs:
- 6 rules (coding-style, git-workflow, testing, security, typescript, python) to ~/.claude/rules/
- 3 hooks (session-start, stop, pre-compact) to ~/.claude/hooks/
- User-level CLAUDE.md to ~/.claude/CLAUDE.md (if not already present)

## Step 2: Verify Installation

Confirm all files are in place:

```bash
echo "=== Rules ===" && ls ~/.claude/rules/
echo "=== Hooks ===" && ls ~/.claude/hooks/
echo "=== User CLAUDE.md ===" && cat ~/.claude/CLAUDE.md
```

All 6 rule files, 3 hook scripts, and the CLAUDE.md should be present.

## Step 3: Run Tests

From the repo directory, run the test suite to validate everything:

```bash
cd ~/Skills-and-others
bash tests/test-hooks.sh
bash tests/test-configs.sh
```

All tests should pass (30/30).

## Step 4: Register Hooks in User Settings

The hooks need to be registered in the user-level settings. Check if ~/.claude/settings.json exists. If it does, merge the hook configuration into it. If not, create it with:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/hooks/session-start.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/hooks/stop.sh"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/hooks/pre-compact.sh"
          }
        ]
      }
    ]
  }
}
```

Important: If settings.json already has content (like permissions or other hooks), MERGE the hooks — don't overwrite the file.

## Step 5: Customize User CLAUDE.md (Optional)

Read ~/.claude/CLAUDE.md and ask me if I want to customize any of these sections:
- Preferred languages (currently TypeScript + Python)
- Coding style preferences
- Git workflow conventions
- Testing standards
- Any project-specific context I want globally available

## Step 6: Verify Everything Works

Run a final verification:

```bash
echo "=== Installation Summary ==="
echo "Rules:" && ls ~/.claude/rules/ | wc -l
echo "Hooks:" && ls ~/.claude/hooks/ | wc -l
echo "User CLAUDE.md:" && [ -f ~/.claude/CLAUDE.md ] && echo "Present" || echo "Missing"
echo "User settings.json:" && [ -f ~/.claude/settings.json ] && echo "Present" || echo "Missing"
echo ""
echo "Setup complete! These configurations will be active in all future Claude Code sessions."
```

Report the results and confirm everything is installed correctly.
~~~

</details>

### Multi-Device Sync

To keep configurations in sync across multiple devices, pull the latest and re-run the installer:

```bash
cd ~/Skills-and-others
git pull
./install.sh typescript python
```

Or add this to your shell profile (`.bashrc` / `.zshrc`) for automatic sync:

```bash
# Sync Claude Code config on shell startup (runs only if repo exists)
[ -d ~/Skills-and-others ] && (cd ~/Skills-and-others && git pull -q 2>/dev/null && ./install.sh typescript python > /dev/null 2>&1)
```
