# Verification Skill

## Purpose
Run a structured verification loop: tests, lint, typecheck, and build.

## When to Use
- After implementing changes
- Before committing code
- When `/verify` command is invoked

## Methodology

1. **Detect Project Type** — Check for package.json, pyproject.toml, go.mod, Cargo.toml, etc.
2. **Run Tests** — Execute the project's test suite. Capture output.
3. **Run Linter** — Execute lint checks (eslint, ruff, golangci-lint, clippy, etc.).
4. **Run Type Checker** — Execute type checks (tsc, mypy, etc.) if applicable.
5. **Run Build** — Execute build command if applicable.
6. **Report Results** — Summarize pass/fail for each step.

## Detection Rules

| File Present | Test Command | Lint Command | Type Check | Build |
|---|---|---|---|---|
| package.json | `npm test` | `npm run lint` | `npx tsc --noEmit` | `npm run build` |
| pyproject.toml | `pytest` | `ruff check .` | `mypy .` | — |
| requirements.txt | `pytest` | `ruff check .` | `mypy .` | — |
| go.mod | `go test ./...` | `golangci-lint run` | — | `go build ./...` |
| Cargo.toml | `cargo test` | `cargo clippy` | — | `cargo build` |

## Output Format

| Check | Status | Details |
|-------|--------|---------|
| Tests | PASS/FAIL | X passed, Y failed |
| Lint | PASS/FAIL | N warnings, M errors |
| Types | PASS/FAIL | N errors |
| Build | PASS/FAIL | — |
