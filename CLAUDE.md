# Skills-and-others

Multi-platform AI configuration system. Separates Claude Code and OpenClaw content.

## Project Purpose

This repository is a modular configuration system for two AI platforms:
- **Claude Code** (`claude/`) -- Skills, agents, rules, hooks, contexts, examples
- **Hermes** (`hermes/`) -- Skills for the Hermes agent platform (mini1+mini2 cluster)

## Architecture

```
claude/                          # Claude Code configuration
  skills/<name>/SKILL.md         # Workflow skills with frontmatter
  agents/<name>.md               # Subagent definitions with frontmatter
  rules/common/                  # Always-on coding guidelines
  rules/<language>/              # Language-specific rules
  contexts/<mode>.md             # Dynamic system prompt modes
  examples/                      # Example CLAUDE.md templates
  mcp-configs/                   # MCP server configuration templates
  memory-persistence/            # Session state save/load scripts
  tests/                         # Validation test suite
  install.sh                     # Configuration installer
hermes/                          # Hermes Agent Platform
  skills/<name>/SKILL.md         # Hermes workflow skills
.claude/                         # Active hooks and settings
  hooks/                         # Lifecycle hook scripts
  settings.json                  # Hook registration
```

## Critical Rules

- All shell scripts MUST use `set -euo pipefail`
- All shell scripts MUST be executable (`chmod +x`)
- All skills MUST have frontmatter (name, description, allowed-tools, model)
- All agents MUST have frontmatter (name, tools, model, maxTurns)
- Hook scripts MUST output valid JSON when producing structured output
- Keep files under 400 lines; split if larger
- No hardcoded secrets or credentials anywhere
- Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`
- Claude Code content goes in `claude/`, Hermes content goes in `hermes/`
- All skills were optimized via the autoresearch loop (baseline -> eval -> iterate -> 100%)

## Testing

```bash
bash claude/tests/test-hooks.sh       # Validate hooks
bash claude/tests/test-configs.sh     # Validate configs
shellcheck .claude/hooks/*.sh         # Lint shell scripts
```

## File Conventions

- Hook scripts: Bash, `.sh` extension, executable, in `.claude/hooks/`
- Skills: `claude/skills/<name>/SKILL.md` (with frontmatter)
- Agents: `claude/agents/<name>.md` (with frontmatter)
- Rules: `claude/rules/<category>/<name>.md`
- Contexts: `claude/contexts/<mode>.md`
