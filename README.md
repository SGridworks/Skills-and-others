# Skills-and-others

Multi-platform AI configuration system for SGridworks. Separates Claude Code and OpenClaw content into dedicated directories.

## Quick Start

```bash
git clone https://github.com/SGridworks/Skills-and-others.git
cd Skills-and-others
claude/install.sh typescript python  # Install rules for your languages

# For Cursor users
claude/install.sh --target cursor typescript
```

## Structure

```
claude/                  # Claude Code configuration
  skills/                # 6 workflow skills (code-review, tdd, plan, verify, build-fix, learning)
  agents/                # 5 subagent definitions
  rules/                 # Coding guidelines (common + typescript, python, golang)
  contexts/              # Dynamic system prompt modes (dev, review, research)
  examples/              # Example CLAUDE.md templates
  mcp-configs/           # MCP server configuration templates
  memory-persistence/    # Session state save/load scripts
  tests/                 # Validation test suite
  install.sh             # Configuration installer
openclaw/                # OpenClaw 14-agent system configuration (future)
.claude/                 # Active hooks and settings
  hooks/                 # Lifecycle hook scripts (4 hooks)
  settings.json          # Hook registration
```

## Claude Code Skills

All skills have frontmatter with `allowed-tools`, `model`, and `user-invocable` fields.

| Skill | Model | Purpose |
|-------|-------|---------|
| `/code-review` | sonnet | Structured review with severity-ranked findings |
| `/tdd` | inherit | Test-driven development workflow |
| `/plan` | sonnet | Phased implementation planning |
| `/verify` | haiku | Run tests, lint, typecheck, build |
| `/build-fix` | inherit | Diagnose and fix build errors |
| `/learn` | sonnet | Extract reusable patterns from sessions |

## Claude Code Agents

All agents have frontmatter with `model`, `maxTurns`, and `permissionMode` fields.

| Agent | Model | Max Turns | Purpose |
|-------|-------|-----------|---------|
| planner | sonnet | 15 | Feature implementation planning |
| code-reviewer | sonnet | 10 | Quality and security review |
| tdd-guide | inherit | 20 | Test-driven development guidance |
| security-reviewer | sonnet | 10 | Vulnerability identification |
| build-resolver | inherit | 15 | Build error resolution (worktree isolated) |

## Context Modes

Use with `claude --system-prompt "$(cat claude/contexts/dev.md)"`:

- **dev** -- Code-first, explain after
- **review** -- Analyze before suggesting, severity-ranked findings
- **research** -- Understand before acting, evidence-based

## Hooks

| Event | Script | Purpose |
|-------|--------|---------|
| SessionStart | session-start.sh | Dependency install, state restoration |
| Stop | stop.sh | Track session activity |
| PreCompact | pre-compact.sh | Save state before context compaction |
| PreToolUse | guard-bash.sh | Block destructive Bash commands |

## Examples

See `claude/examples/` for complete CLAUDE.md templates:
- `user-CLAUDE.md` -- User-level global config (`~/.claude/CLAUDE.md`)
- `saas-nextjs-CLAUDE.md` -- Next.js + Supabase + Stripe
- `go-microservice-CLAUDE.md` -- Go + gRPC + PostgreSQL
- `django-api-CLAUDE.md` -- Django REST + Celery

## Testing

```bash
bash claude/tests/test-hooks.sh       # Validate hooks
bash claude/tests/test-configs.sh     # Validate configs
shellcheck .claude/hooks/*.sh         # Lint shell scripts
```

## Installation

```bash
claude/install.sh --help                     # Show usage
claude/install.sh typescript                 # Install TS rules for Claude Code
claude/install.sh --target cursor python     # Install Python rules for Cursor
claude/install.sh typescript python golang   # Install multiple languages
```

---

## Setup Prompt -- Full Installation via Claude Code

Copy and paste the prompt below into a new Claude Code session to have Claude set up everything automatically on any device.

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
claude/install.sh typescript python
```

This installs:
- 7 rules (coding-style, git-workflow, testing, security, typescript, python, golang) to ~/.claude/rules/
- 4 hooks (session-start, stop, pre-compact, guard-bash) to ~/.claude/hooks/
- User-level CLAUDE.md to ~/.claude/CLAUDE.md (if not already present)

## Step 2: Verify Installation

Confirm all files are in place:

```bash
echo "=== Rules ===" && ls ~/.claude/rules/
echo "=== Hooks ===" && ls ~/.claude/hooks/
echo "=== User CLAUDE.md ===" && cat ~/.claude/CLAUDE.md
```

All 7 rule files, 4 hook scripts, and the CLAUDE.md should be present.

## Step 3: Run Tests

From the repo directory, run the test suite to validate everything:

```bash
cd ~/Skills-and-others
bash claude/tests/test-hooks.sh
bash claude/tests/test-configs.sh
```

All tests should pass.

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
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/hooks/guard-bash.sh"
          }
        ]
      }
    ]
  }
}
```

Important: If settings.json already has content (like permissions or other hooks), MERGE the hooks -- don't overwrite the file.

## Step 5: Customize User CLAUDE.md (Optional)

Read ~/.claude/CLAUDE.md and ask me if I want to customize any of these sections:
- Preferred languages (currently TypeScript + Python + Shell/Bash)
- Coding style preferences
- Git workflow conventions
- Testing standards
- Environment context (Mac Mini cluster, OpenClaw, local LLM stack)

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
claude/install.sh typescript python golang
```

Or add this to your shell profile (`.bashrc` / `.zshrc`) for automatic sync:

```bash
# Sync Claude Code config on shell startup (runs only if repo exists)
[ -d ~/Skills-and-others ] && (cd ~/Skills-and-others && git pull -q 2>/dev/null && claude/install.sh typescript python golang > /dev/null 2>&1)
```
