# Implementation Prompts

Feed these prompts to Claude Code to implement improvements to Skills-and-others.

## Phases (execute in order)

| Phase | File | Description | Effort |
|-------|------|-------------|--------|
| 1 | `phase-1-foundation.md` | CLAUDE.md, .gitignore, enhanced hooks | Low |
| 2 | `phase-2-skills-commands-rules.md` | Skills, slash commands, coding rules | Medium |
| 3 | `phase-3-infrastructure.md` | MCP configs, memory persistence, CI/CD, tests | Medium |
| 4 | `phase-4-agents-contexts.md` | Specialized agents, context modes | Medium |
| 5 | `phase-5-examples-installer.md` | Example configs, installer, updated docs | Low |

## How to Use

1. Open a Claude Code session in the Skills-and-others repo
2. Paste the contents of the phase file as your prompt
3. Let Claude implement everything in the phase
4. Verify and commit
5. Move to the next phase

Each phase is self-contained and builds on the previous one.
