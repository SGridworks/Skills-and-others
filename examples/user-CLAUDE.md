# Global Claude Code Configuration

## Who I Am
Solo developer running a two-Mac-Mini cluster (mini1 + mini2) with OpenClaw as my AI agent platform. I build energy infrastructure software (BTM-Optimize) and maintain a local LLM inference stack (Qwen 3.5 9B, Kimi K2.5).

## Preferences

### Code Style
- Be concise — lead with code, not explanations
- No emojis in code, comments, or commit messages
- Prefer immutability and early returns
- Functions under 50 lines, files under 400 lines
- No commented-out code — delete it, git has history
- When fixing config issues, explain what was wrong and why the fix works

### Git
- Conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
- Commit messages explain WHY, not WHAT
- Never commit secrets, credentials, or .env files
- PR titles under 70 characters

### Testing
- TDD when possible — write tests before implementation
- Target 80%+ coverage for new code
- Every bug fix gets a regression test
- Mock external dependencies, not internal logic

### Security
- Never hardcode secrets — use environment variables
- Parameterized queries only — no string interpolation for SQL
- Validate all user input at system boundaries
- Audit dependencies for known vulnerabilities

### Languages
- **TypeScript**: strict mode, `unknown` over `any`, Zod for runtime validation, async/await
- **Python**: type hints on all signatures, pathlib over os.path, ruff for linting, pytest for testing
- **Shell/Bash**: used heavily for LaunchAgents, health checks, and automation scripts

## Workflow
- Research the codebase before making changes — read files before editing
- Use existing patterns from the codebase — don't invent new ones
- When stuck after 2 attempts, step back and rethink the approach
- Commit frequently with descriptive messages
- Run tests and lint before considering work complete

## Environment Context
- **Machine**: Mac Mini M-series, macOS (darwin), zsh
- **Cluster**: mini1 (192.168.4.26) + mini2 (192.168.4.28)
- **OpenClaw**: 14-agent system (main + 13 specialized agents), Telegram + Discord channels
- **Local LLM**: Qwen 3.5 9B via llama-server cluster (nginx round-robin on port 8085)
- **Cloud LLM**: Moonshot Kimi K2.5 (primary orchestrator model)
- **Key configs**: `~/.openclaw/openclaw.json`, LaunchAgents in `~/Library/LaunchAgents/`
- **Active project**: BTM-Optimize (Python/Pyomo energy optimization SaaS)

## Important Notes
- GPU memory is limited (16GB shared) — Ollama and llama-server cannot run simultaneously
- OpenClaw config changes often need a gateway restart (`launchctl kickstart`)
- The `~/.openclaw/scripts/` directory has maintenance scripts — check there before writing new ones
- Auto-memory lives in `~/.claude/projects/-Users-mini1-samwise/memory/` — consult it for detailed setup notes

## Project Configuration
- Claude Code config repo: https://github.com/SGridworks/Skills-and-others
- Skills, agents, commands, and examples are available there
- Use `contexts/dev.md` for code-first sessions, `contexts/review.md` for reviews
