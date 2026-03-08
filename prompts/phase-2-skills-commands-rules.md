# Phase 2: Skills, Commands, and Rules

Implement skills, slash commands, and coding rules. This phase builds on Phase 1 (CLAUDE.md, hooks, .gitignore must already exist).

## Target State After This Phase

```
skills/
  code-review/SKILL.md
  tdd/SKILL.md
  plan/SKILL.md
  verify/SKILL.md
  build-fix/SKILL.md
  continuous-learning/SKILL.md
commands/
  plan.md
  tdd.md
  code-review.md
  verify.md
  build-fix.md
  learn.md
rules/
  common/
    coding-style.md
    git-workflow.md
    testing.md
    security.md
  typescript/
    typescript.md
  python/
    python.md
```

---

## Task 2.1: Create Skills

Each skill is a directory containing a `SKILL.md` file.

### skills/code-review/SKILL.md

```markdown
# Code Review Skill

## Purpose
Perform a structured code review with severity-ranked findings.

## When to Use
- Before merging PRs
- After significant code changes
- When asked to review code quality

## Methodology

1. **Understand Context** — Read the changed files and understand the purpose of the changes.
2. **Check Correctness** — Does the code do what it claims? Are there logic errors?
3. **Check Security** — OWASP Top 10, injection risks, credential exposure, input validation.
4. **Check Performance** — N+1 queries, unnecessary allocations, missing indexes, blocking calls.
5. **Check Maintainability** — Naming, structure, duplication, complexity, test coverage.
6. **Rank Findings** — Categorize as Critical / High / Medium / Low.

## Output Format

### Critical
- [file:line] Description and fix

### High
- [file:line] Description and fix

### Medium
- [file:line] Description and fix

### Low
- [file:line] Description and fix

### Summary
[1-2 sentences on overall quality]

## Rules
- Never approve code with Critical findings
- Always check for hardcoded secrets
- Verify error handling at system boundaries
- Check that tests exist for new functionality
```

### skills/tdd/SKILL.md

```markdown
# TDD Workflow Skill

## Purpose
Enforce test-driven development: write tests first, then implement.

## When to Use
- Implementing new features
- Fixing bugs (write regression test first)
- When `/tdd` command is invoked

## Methodology

1. **Clarify Requirements** — Understand what the feature should do. Define user-visible behavior.
2. **Write Test Cases** — Write failing tests that describe the expected behavior. Run them — they MUST fail.
3. **Minimal Implementation** — Write the minimum code to make tests pass. No extra features.
4. **Run Tests** — All tests must pass. If not, fix implementation (not tests).
5. **Refactor** — Clean up while keeping tests green. Extract helpers, rename, simplify.
6. **Coverage Check** — Target 80%+ line coverage. Add edge case tests if below.

## Rules
- NEVER write implementation before tests
- Tests must fail before implementation exists
- Each test should test ONE behavior
- Test names should describe the behavior, not the method
- Use arrange/act/assert (or given/when/then) structure
- Mock external dependencies, not internal logic
- Integration tests for API boundaries, unit tests for logic
```

### skills/plan/SKILL.md

```markdown
# Implementation Planning Skill

## Purpose
Decompose a feature request into a phased implementation plan with exact file paths, dependencies, and verification steps.

## When to Use
- Before starting any non-trivial feature
- When asked to plan implementation
- When `/plan` command is invoked

## Methodology

1. **Understand the Request** — Clarify ambiguities. Identify acceptance criteria.
2. **Research the Codebase** — Find related files, patterns, and conventions already in use.
3. **Identify Changes** — List every file that needs to be created or modified.
4. **Order by Dependency** — Phase changes so each phase is independently testable.
5. **Define Verification** — For each phase, specify how to verify it works.

## Output Format

### Requirements
- [bullet list of what this feature must do]

### Phase 1: [name]
**Files:**
- `path/to/file.ts` — [what changes]
- `path/to/test.ts` — [what tests]

**Verification:**
- [ ] [how to verify this phase works]

### Phase 2: [name]
...

### Risks
- [potential issues and mitigations]

### Out of Scope
- [what this plan deliberately does NOT cover]

## Rules
- Always research the codebase before planning
- Never plan changes to files you haven't read
- Each phase must be independently deployable
- Include test files in every phase
- Call out risks and unknowns explicitly
```

### skills/verify/SKILL.md

```markdown
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
```

### skills/build-fix/SKILL.md

```markdown
# Build Fix Skill

## Purpose
Diagnose and resolve build, compilation, and dependency errors.

## When to Use
- When build/compile fails
- When tests fail due to infrastructure (not logic) issues
- When `/build-fix` command is invoked

## Methodology

1. **Capture Error Output** — Get the full error message and stack trace.
2. **Classify Error Type:**
   - **Dependency** — Missing package, version conflict, lock file mismatch
   - **Type/Syntax** — Type errors, syntax errors, import errors
   - **Configuration** — Wrong tsconfig, missing env vars, bad paths
   - **Runtime** — Port conflicts, permission issues, missing binaries
3. **Research** — Check the specific file and line referenced in the error.
4. **Fix** — Apply the minimal fix. Do NOT refactor surrounding code.
5. **Verify** — Re-run the failing command to confirm the fix works.
6. **Explain** — State what was wrong and why the fix works.

## Rules
- Fix the error, not symptoms — find root cause
- Minimal changes only — do not refactor
- Always verify the fix by re-running the failing command
- If a fix requires a breaking change, warn the user first
- Never delete lock files as a first resort — investigate why they're wrong
```

### skills/continuous-learning/SKILL.md

```markdown
# Continuous Learning Skill

## Purpose
Extract reusable patterns from the current session and persist them as learned instincts.

## When to Use
- At the end of productive sessions (10+ messages)
- When `/learn` command is invoked
- When a novel problem-solving pattern emerges

## What to Extract

1. **Error Resolution Patterns** — How specific errors were diagnosed and fixed
2. **User Corrections** — When the user corrected the approach, what was learned
3. **Workarounds** — Non-obvious solutions to environment or tooling issues
4. **Project Conventions** — Patterns specific to this codebase
5. **Debugging Techniques** — Effective diagnostic approaches

## Output Format

Each learned pattern saved as markdown:

```
# Pattern: [short name]

## Context
[When does this pattern apply?]

## Problem
[What problem does it solve?]

## Solution
[The approach that works]

## Confidence
[high/medium/low]

## Source
[Session date and brief context]
```

## Storage
Patterns saved to `~/.claude/skills/learned/` as individual `.md` files.

## Rules
- Only extract patterns that are genuinely reusable
- Don't extract trivial or obvious things
- Include enough context that the pattern is useful without the original session
- Assign honest confidence levels
```

---

## Task 2.2: Create Commands

Each command is a markdown file with YAML frontmatter.

### commands/plan.md

```markdown
---
name: plan
description: Create a structured implementation plan for a feature
arguments: description
---

Use the Implementation Planning skill to create a detailed, phased plan for the following feature:

$ARGUMENTS

Research the codebase first. Identify all files that need changes. Order phases by dependency. Include verification steps for each phase. Call out risks and unknowns.
```

### commands/tdd.md

```markdown
---
name: tdd
description: Start a test-driven development workflow
arguments: feature (optional)
---

Use the TDD Workflow skill. Follow the strict TDD cycle:

1. Write failing tests FIRST
2. Run tests — confirm they FAIL
3. Write minimal implementation
4. Run tests — confirm they PASS
5. Refactor while keeping tests green
6. Check coverage (target 80%+)

Feature to implement: $ARGUMENTS

If no feature specified, ask what to implement.
```

### commands/code-review.md

```markdown
---
name: code-review
description: Run a structured code review on recent changes
arguments: scope (optional — file path, branch, or "staged")
---

Use the Code Review skill to review code changes.

Scope: $ARGUMENTS

If no scope specified, review all uncommitted changes (staged + unstaged).

Rank all findings by severity: Critical > High > Medium > Low. Never approve code with Critical findings. Always check for hardcoded secrets.
```

### commands/verify.md

```markdown
---
name: verify
description: Run verification checks — tests, lint, typecheck, build
arguments: none
---

Use the Verification skill. Detect the project type and run all applicable checks:

1. Tests
2. Linter
3. Type checker
4. Build

Report results in a summary table. If anything fails, show the details and suggest fixes.
```

### commands/build-fix.md

```markdown
---
name: build-fix
description: Diagnose and fix build/compile errors
arguments: error message (optional)
---

Use the Build Fix skill.

Error context: $ARGUMENTS

If no error provided, run the build command, capture the error, and fix it. Always verify the fix by re-running the failing command.
```

### commands/learn.md

```markdown
---
name: learn
description: Extract reusable patterns from this session
arguments: none
---

Use the Continuous Learning skill. Review this session and extract:

1. Error resolution patterns
2. User corrections and what was learned
3. Workarounds discovered
4. Project conventions identified
5. Effective debugging techniques

Save each pattern as a markdown file in `~/.claude/skills/learned/`. Only extract genuinely reusable patterns. Assign honest confidence levels.
```

---

## Task 2.3: Create Rules

### rules/common/coding-style.md

```markdown
# Coding Style Rules

## Universal
- Functions should do one thing and be under 50 lines
- Prefer immutability — create new objects rather than mutating
- Use descriptive names — no single-letter variables except loop counters
- No commented-out code — delete it (git has history)
- No TODO comments without a linked issue
- Keep files under 400 lines; split if larger
- Prefer early returns over deep nesting
- No magic numbers — use named constants

## Formatting
- Use the project's configured formatter (Prettier, Black, gofmt, etc.)
- Consistent indentation (follow existing codebase)
- No trailing whitespace
- Files end with a single newline
```

### rules/common/git-workflow.md

```markdown
# Git Workflow Rules

## Commits
- Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
- Commit messages explain WHY, not WHAT (the diff shows what)
- One logical change per commit
- Never commit secrets, credentials, or .env files

## Branches
- Feature branches from main/master
- Branch names: `feat/description`, `fix/description`, `refactor/description`
- Keep branches short-lived — merge or rebase frequently

## Pull Requests
- PR title under 70 characters
- PR body includes: Summary (what + why), Test Plan, any migration notes
- All CI checks must pass before merge
- Squash-merge to keep main history clean
```

### rules/common/testing.md

```markdown
# Testing Rules

## Standards
- Target 80%+ line coverage for new code
- Every bug fix must include a regression test
- Every new feature must include tests
- Tests should be deterministic — no flaky tests

## Structure
- Use arrange/act/assert (given/when/then) pattern
- One assertion concept per test
- Test names describe behavior: `should_return_404_when_user_not_found`
- Mock external dependencies, not internal logic

## What to Test
- Business logic and domain rules
- API boundaries (request/response contracts)
- Error handling paths
- Edge cases (empty, null, boundary values)

## What NOT to Test
- Framework internals
- Simple getters/setters
- Third-party library behavior
- Implementation details that may change
```

### rules/common/security.md

```markdown
# Security Rules

## Secrets
- NEVER hardcode secrets, API keys, passwords, or tokens
- Use environment variables or secret managers
- Never log secrets or include them in error messages
- Add secret patterns to .gitignore

## Input Validation
- Validate all user input at system boundaries
- Use parameterized queries — never interpolate user input into SQL
- Sanitize output to prevent XSS
- Validate and sanitize file paths to prevent path traversal

## Authentication & Authorization
- Never store passwords in plaintext — use bcrypt/argon2
- Validate JWT tokens on every request
- Check authorization for every protected resource
- Use HTTPS for all external communication

## Dependencies
- Keep dependencies updated
- Audit for known vulnerabilities (`npm audit`, `pip audit`, `govulncheck`)
- Pin dependency versions in lock files
- Review new dependency additions for trust signals
```

### rules/typescript/typescript.md

```markdown
# TypeScript Rules

- Use strict mode (`"strict": true` in tsconfig)
- Prefer `interface` over `type` for object shapes
- Use `unknown` over `any` — narrow with type guards
- Use `const` by default, `let` only when reassignment is needed
- Use Zod or similar for runtime validation of external data
- Prefer `async/await` over raw Promises
- Handle all Promise rejections
- Use discriminated unions for state management
- Prefer `Map`/`Set` over plain objects for dynamic keys
- No `!` non-null assertions except in tests
```

### rules/python/python.md

```markdown
# Python Rules

- Use type hints on all function signatures
- Use `pathlib.Path` over `os.path`
- Use f-strings for string formatting
- Use dataclasses or Pydantic models for structured data
- Use `contextlib` for resource management
- Prefer comprehensions over manual loops when clear
- Use `logging` module, not `print()` for production code
- Handle exceptions specifically — never bare `except:`
- Use `pytest` for testing with fixtures and parametrize
- Use `ruff` for linting and formatting
```

---

## Commit

```bash
git add skills/ commands/ rules/
git commit -m "feat: add skills, commands, and rules — code-review, tdd, plan, verify, build-fix, continuous-learning"
```
