---
name: tdd
description: Test-driven development workflow -- tests before code
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
model: inherit
user-invocable: true
arguments: feature (optional)
---

# TDD Workflow Skill

Follow the strict TDD cycle:

1. Write failing tests FIRST
2. Run tests -- confirm they FAIL
3. Write minimal implementation
4. Run tests -- confirm they PASS
5. Refactor while keeping tests green
6. Check coverage (target 80%+)

Feature to implement: $ARGUMENTS

If no feature specified, ask what to implement.

## Rules
- NEVER write implementation before tests
- Tests must fail before implementation exists
- Each test should test ONE behavior
- Test names should describe the behavior, not the method
- Use arrange/act/assert (or given/when/then) structure
- Mock external dependencies, not internal logic
- Integration tests for API boundaries, unit tests for logic
