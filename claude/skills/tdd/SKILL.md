---
name: tdd
description: >
  Guide test-driven development with strict red-green-refactor methodology. Use when
  user says "write tests first", "TDD", "test-driven", "red green refactor", "start
  with tests", "I want to do TDD", or asks to implement a feature using test-first
  approach. Do NOT use for writing tests after implementation is done, running
  existing tests without writing new ones (use verify skill instead), or for
  fixing failing tests that already exist.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
model: inherit
user-invocable: true
arguments: feature (optional)
compatibility: Requires a test runner installed in the project (jest, pytest, go test, etc.)
license: MIT
metadata:
  author: SGridworks
  version: 2.0.0
  category: workflow
  tags: [testing, tdd, development, quality]
---

# TDD Workflow Skill

Feature to implement: $ARGUMENTS

If no feature specified, ask what to implement.

## Instructions

### Step 1: Clarify Requirements
Understand what the feature should do. Define user-visible behavior and acceptance criteria.

### Step 2: Write Failing Tests (RED)
Write test cases that describe the expected behavior. Show the test code written. Run them -- they MUST fail. If they pass, the tests are not testing new behavior.

### Step 3: Minimal Implementation (GREEN)
Write the minimum code to make tests pass. No extra features, no premature optimization. Just make the tests green.

### Step 4: Run Tests
All tests must pass. If not, fix implementation (not tests). Never modify tests to make them pass unless the test was wrong.

### Step 5: Refactor
Clean up while keeping tests green. Extract helpers, rename for clarity, simplify logic. Run tests after each refactor step.

### Step 6: Coverage Check
Target 80%+ line coverage. Add edge case tests if below threshold.

## Examples

Example 1: New feature with TDD
User says: "Use TDD to add a password strength validator"
Actions:
1. Write tests: weak password returns false, strong password returns true, edge cases
2. Run tests -- confirm all FAIL
3. Implement `validatePassword()` with minimum logic
4. Run tests -- confirm all PASS
5. Refactor: extract complexity rules, rename for clarity
Result: Fully tested feature with 90%+ coverage

Example 2: Bug fix with regression test
User says: "Fix the login bug -- users with + in email can't log in. Use TDD."
Actions:
1. Write test: `should_accept_email_with_plus_sign`
2. Run test -- confirm it FAILS (reproduces the bug)
3. Fix the email validation regex
4. Run test -- confirm it PASSES
Result: Bug fixed with regression test preventing recurrence

## Troubleshooting

Error: Tests pass before implementation
Cause: Tests are not specific enough or test already-existing behavior
Solution: Make tests more specific to the new behavior being added

Error: Can't achieve 80% coverage
Cause: Complex branching logic or error handling paths
Solution: Add edge case tests for each branch -- empty inputs, nulls, boundary values

## Output Format

### RED Phase
```
Test: [test name]
Status: FAILING (expected)
Error: [failure message]
```

### GREEN Phase
```
Test: [test name]
Status: PASSING
Implementation: [file:line]
```

### REFACTOR Phase
```
Change: [what was refactored]
Tests: Still PASSING
```

### Summary
| Phase | Tests Written | Tests Passing | Coverage |
|-------|--------------|---------------|----------|
| RED   | N            | 0             | --       |
| GREEN | N            | N             | X%       |
| REFACTOR | N         | N             | X%       |

## Rules
- NEVER write implementation before tests
- Tests must fail before implementation exists
- Each test should test ONE behavior
- Test names should describe the behavior, not the method
- Use arrange/act/assert (or given/when/then) structure
- Mock external dependencies, not internal logic
- Integration tests for API boundaries, unit tests for logic
