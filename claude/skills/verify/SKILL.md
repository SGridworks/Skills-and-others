---
name: verify
description: >
  Run structured verification checks including tests, linting, type checking, and
  build. Use when user says "run the tests", "verify everything works", "check the
  build", "run lint", "does it compile", "CI checks", or asks to validate code before
  committing or deploying. Do NOT use for reviewing code quality (use code-review
  skill) or for fixing build errors (use build-fix skill).
allowed-tools: Read, Grep, Glob, Bash
model: haiku
user-invocable: true
compatibility: Requires project with a test runner, linter, or build tool installed.
license: MIT
metadata:
  author: SGridworks
  version: 2.0.0
  category: workflow
  tags: [testing, linting, build, ci, verification]
---

# Verification Skill

Detect the project type and run all applicable checks. Report results in a summary table. If anything fails, show the details and suggest fixes.

## Instructions

### Step 1: Detect Project Type
Check for project manifest files to determine the tech stack and available commands.

### Step 2: Run Tests
Execute the project's test suite. Capture output including pass/fail counts.

### Step 3: Run Linter
Execute lint checks. Capture warnings and errors.

### Step 4: Run Type Checker
Execute type checks if the project uses a typed language.

### Step 5: Run Build
Execute the build command if applicable.

### Step 6: Report Results
Summarize pass/fail for each step in the output table. If anything failed, show the relevant error output and suggest a fix.

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

## Examples

Example 1: Verify a Node.js project
User says: "Run all checks before I push"
Actions:
1. Detect package.json -- Node.js project
2. Run `npm test` -- 42 passed, 0 failed
3. Run `npm run lint` -- 0 errors, 2 warnings
4. Run `npx tsc --noEmit` -- clean
5. Run `npm run build` -- success
Result: Summary table showing all PASS

Example 2: Verify with failures
User says: "Does it compile?"
Actions:
1. Detect go.mod -- Go project
2. Run `go test ./...` -- 1 test failed
3. Run `golangci-lint run` -- 3 issues found
4. Run `go build ./...` -- success
Result: Table with test/lint failures, error details shown, fix suggestions

## Troubleshooting

Error: Command not found (e.g., ruff, golangci-lint)
Cause: Linter or tool not installed in the environment
Solution: Skip that check and note it in the report. Suggest installation command.

Error: No test files found
Cause: Project has no tests yet
Solution: Report "No tests found" rather than failing. Suggest creating tests.

## Rules
- NEVER modify code -- only read and run commands
- NEVER skip a check because an earlier check failed -- run all applicable checks
- Run all applicable checks, not just one
- Report failures with enough detail to diagnose
- Suggest fixes for common failures
- If any check fails, suggest: "Run /build-fix to diagnose and fix the failures"
- End every report with a summary count: "X passed, X failed, X skipped"
