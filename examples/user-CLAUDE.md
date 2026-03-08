# SGridworks — Global Claude Code Configuration

## Who I Am
SGridworks developer. I use Claude Code across multiple devices and projects.

## Preferences

### Code Style
- Be concise — lead with code, not explanations
- No emojis in code, comments, or commit messages
- Prefer immutability and early returns
- Functions under 50 lines, files under 400 lines
- No commented-out code — delete it, git has history

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

## Workflow
- Research the codebase before making changes — read files before editing
- Use existing patterns from the codebase — don't invent new ones
- When stuck after 2 attempts, step back and rethink the approach
- Commit frequently with descriptive messages
- Run tests and lint before considering work complete

## Project Configuration
- My Claude Code config repo is at: https://github.com/SGridworks/Skills-and-others
- Skills, agents, commands, and examples are available there
- Use `contexts/dev.md` for code-first sessions, `contexts/review.md` for reviews
