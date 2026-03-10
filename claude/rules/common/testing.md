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
