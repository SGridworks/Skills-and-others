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
