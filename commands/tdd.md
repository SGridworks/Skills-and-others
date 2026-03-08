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
