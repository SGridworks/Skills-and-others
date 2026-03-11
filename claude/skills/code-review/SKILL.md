---
name: code-review
description: >
  Perform structured code reviews with severity-ranked findings across correctness,
  security, performance, and maintainability. Use when user says "review this code",
  "check my PR", "code review", "look for bugs", "review for security issues",
  "check code quality", or asks about potential issues in their changes. Do NOT use
  for general code questions, explaining code, or writing new code.
allowed-tools: Read, Grep, Glob
model: sonnet
user-invocable: true
arguments: scope (optional -- file path, branch, or "staged")
license: MIT
metadata:
  author: SGridworks
  version: 2.0.0
  category: code-quality
  tags: [review, security, quality, best-practices]
---

# Code Review Skill

Scope: $ARGUMENTS

If no scope specified, review all uncommitted changes (staged + unstaged).

## Instructions

### Step 1: Gather Changes
Read all changed files. Use `git diff` for unstaged, `git diff --cached` for staged, or read the specified file/branch. If scope is a file path, read the file directly -- skip git diff.

### Step 2: Understand Context
Determine the purpose of the changes. Read surrounding code to understand intent.

### Step 3: Check Correctness
- Logic errors, off-by-one, null/undefined handling
- Error handling completeness
- Race conditions, deadlocks
- Resource leaks (unclosed connections, file handles)

### Step 4: Check Security
- Injection vulnerabilities (SQL, XSS, command injection)
- Hardcoded credentials or secrets
- Missing input validation at system boundaries
- Broken authentication/authorization
- Insecure deserialization

### Step 5: Check Performance
- N+1 query patterns
- Unnecessary allocations in hot paths
- Missing database indexes
- Blocking calls in async contexts

### Step 6: Check Maintainability
- Naming clarity and consistency
- Function length and complexity
- Code duplication
- Missing or misleading tests

### Step 7: Rank and Report
Categorize all findings using the severity rubric. You MUST check and report on all 4 dimensions even if Critical issues are found early. Group related instances of the same pattern into a single finding.

## Severity Rubric

- **Critical** -- Exploitable security flaw, data loss bug, or crash in production path
- **High** -- Correctness bug affecting output, missing error handling at boundaries
- **Medium** -- Performance issue, missing validation, resource leak risk
- **Low** -- Naming, style, maintainability, missing tests for non-critical paths

## Output Format

### Critical
- [file:line] [security|correctness|performance|maintainability] Description and suggested fix

### High
- [file:line] [category] Description and suggested fix

### Medium
- [file:line] [category] Description and suggested fix

### Low
- [file:line] [category] Description and suggested fix

### Summary
[1-2 sentences on overall quality and recommendation: approve, request changes, or block]

## Examples

Example 1: Review staged changes
User says: "Review my staged changes before I commit"
Actions:
1. Run `git diff --cached` to see staged changes
2. Read each changed file for full context
3. Check all 4 dimensions (correctness, security, performance, maintainability)
Result: Severity-ranked findings with specific file:line references and fixes

Example 2: Review a specific file
User says: "Review src/auth/login.ts for security issues"
Actions:
1. Read the specified file
2. Focus security review (OWASP Top 10)
3. Check surrounding auth code for consistency
Result: Security-focused findings with remediation steps

## Troubleshooting

Error: No changes found
Cause: No uncommitted changes in the working directory
Solution: Specify a file path or branch to review instead

Error: Too many files changed
Cause: Large diff spanning many files
Solution: Review in batches -- specify individual files or directories

## Rules
- Never approve code with Critical findings
- Always check for hardcoded secrets
- Verify error handling at system boundaries
- Check that tests exist for new functionality
- Suggest fixes, don't just point out problems
- MUST report on all 4 dimensions -- do not short-circuit after finding Critical issues
- Group related instances into a single finding with all line references
