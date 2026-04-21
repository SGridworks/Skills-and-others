---
name: parallel-pr-review
description: "Parallel multi-agent PR review using 3 simultaneous subagents: security audit, code style/correctness, and performance analysis. Each reviewer works independently in a fresh context. Triggers: review this PR, PR review, code review, check my commits, audit this branch."
category: software-development
---

# Parallel PR Review

Three specialized subagents review code simultaneously — fresh context for each, no bias.

## When to Use

Use when asked to review:
- Uncommitted changes (`git diff`)
- A branch or recent commits (`git log`)
- A specific file or directory
- Any PR or code before committing

## Pre-flight: Gather Context

Before spawning subagents:

1. Identify the repo root:
   ```
   git rev-parse --show-toplevel
   ```
2. Get the diff to review:
   ```
   # Uncommitted changes
   git diff HEAD

   # Committed branch diff
   git diff main...HEAD

   # Last N commits
   git log -n 5 --oneline
   ```
3. Identify changed files:
   ```
   git diff --name-only
   ```

## Run Three Parallel Reviewers

Use `delegate_task` with `tasks` (batch mode) — all 3 run simultaneously:

```python
delegate_task(
    tasks=[
        {
            "goal": "SECURITY AUDIT: Review these code changes for security issues.\n\nFocus on:\n- SQL injection, command injection, path traversal\n- Hardcoded credentials, API keys, secrets in code\n- Authentication/authorization bypasses\n- Input validation gaps\n- Dependency vulnerabilities\n- Insecure deserialization\n\nChanged files:\n<LIST_FILES>\n\nDiff:\n<PASTE_DIFF>\n\nRespond with:\n1. Critical issues (must fix before merge)\n2. High issues (should fix)\n3. Medium/low issues (consider fixing)\n4. Safe areas (what not to worry about)\n\nBe specific: file, line, issue, fix.",
            "context": "Security review context: repo root=<REPO_ROOT>\n<ANY_RELEVANT_CONFIG>",
            "toolsets": ["terminal", "file"]
        },
        {
            "goal": "CODE STYLE & CORRECTNESS REVIEW: Review these changes for:\n\nCorrectness:\n- Logic errors, off-by-ones, incorrect assumptions\n- Edge cases not handled\n- Error handling missing or wrong\n- Type correctness (Python type hints, TypeScript types)\n- Test coverage (are new code paths tested?)\n\nStyle:\n- Follows project style conventions\n- Readable variable/function names\n- Clear comments where needed, none where redundant\n- No commented-out dead code\n\nChanged files:\n<LIST_FILES>\n\nDiff:\n<PASTE_DIFF>\n\nRespond with:\n1. Correctness issues (must fix)\n2. Style issues (should fix)\n3. Missing tests (should add)\n4. What was done well",
            "context": "Style review context: repo root=<REPO_ROOT>\n<ANY_RELEVANT_CONFIG>",
            "toolsets": ["terminal", "file"]
        },
        {
            "goal": "PERFORMANCE & ARCHITECTURE REVIEW: Review for:\n\nPerformance:\n- N+1 queries, missing indexes, inefficient queries\n- Unnecessary loops, repeated work, missing caching\n- Large data structure copies\n- Blocking I/O in hot paths\n- Memory leaks or unbounded growth\n\nArchitecture:\n- Does this change follow the existing architecture?\n- Are there dependency cycles?\n- Would this be hard to undo?\n- API/interface changes that break callers?\n\nChanged files:\n<LIST_FILES>\n\nDiff:\n<PASTE_DIFF>\n\nRespond with:\n1. Performance issues (must fix)\n2. Architecture concerns (discuss before merging)\n3. Scalability notes\n4. What is well-designed",
            "context": "Performance review context: repo root=<REPO_ROOT>\n<ANY_RELEVANT_CONFIG>",
            "toolsets": ["terminal", "file"]
        }
    ],
    max_iterations=30
)
```

## Synthesize Results

After all 3 return:

1. Aggregate findings by severity
2. Deduplicate overlapping findings
3. Present as a unified review:

```
## Parallel PR Review Results

### MUST FIX (block merge)
- [SECURITY] file:line — issue
- [CORRECTNESS] file:line — issue

### SHOULD FIX
- [STYLE] file:line — issue
- [PERF] file:line — issue

### CONSIDER
- [ARCH] file:line — concern

### APPROVED
- Areas with no issues found

### Summary
<one sentence verdict: safe to merge / needs fixes / needs discussion>
```

## Important Rules

- **Never modify code during review** — this is a review-only skill
- **Fresh context** is the point — do NOT feed subagents each other's output
- **No bias** — each subagent sees only the diff, not the other reviewers' opinions
- **Be specific** — file paths, line numbers, exact issue descriptions
- **Distinguish opinions from facts** — style is opinion, security bugs are facts
- **If the diff is empty or trivial** — return "Nothing to review" and skip subagents
- **Large diffs (>1000 lines)** — review the most critical files only, flag the rest for manual review
