---
name: verify
description: Run verification checks -- tests, lint, typecheck, build
allowed-tools: Read, Grep, Glob, Bash
model: haiku
user-invocable: true
---

# Verification Skill

Detect the project type and run all applicable checks. Report results in a summary table. If anything fails, show the details and suggest fixes.

## Detection Rules

| File Present | Test Command | Lint Command | Type Check | Build |
|---|---|---|---|---|
| package.json | `npm test` | `npm run lint` | `npx tsc --noEmit` | `npm run build` |
| pyproject.toml | `pytest` | `ruff check .` | `mypy .` | -- |
| requirements.txt | `pytest` | `ruff check .` | `mypy .` | -- |
| go.mod | `go test ./...` | `golangci-lint run` | -- | `go build ./...` |
| Cargo.toml | `cargo test` | `cargo clippy` | -- | `cargo build` |

## Output Format

| Check | Status | Details |
|-------|--------|---------|
| Tests | PASS/FAIL | X passed, Y failed |
| Lint | PASS/FAIL | N warnings, M errors |
| Types | PASS/FAIL | N errors |
| Build | PASS/FAIL | -- |
