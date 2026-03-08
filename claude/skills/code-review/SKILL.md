---
name: code-review
description: Structured review with severity-ranked findings
allowed-tools: Read, Grep, Glob
model: sonnet
user-invocable: true
arguments: scope (optional -- file path, branch, or "staged")
---

# Code Review Skill

Scope: $ARGUMENTS

If no scope specified, review all uncommitted changes (staged + unstaged).

## Methodology

1. **Understand Context** -- Read the changed files and understand the purpose of the changes.
2. **Check Correctness** -- Does the code do what it claims? Are there logic errors?
3. **Check Security** -- OWASP Top 10, injection risks, credential exposure, input validation.
4. **Check Performance** -- N+1 queries, unnecessary allocations, missing indexes, blocking calls.
5. **Check Maintainability** -- Naming, structure, duplication, complexity, test coverage.
6. **Rank Findings** -- Categorize as Critical / High / Medium / Low.

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
