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
