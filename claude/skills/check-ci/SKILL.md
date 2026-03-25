---
name: check-ci
description: >
  Scan PR status, CI failures, review requests, and issue assignments across
  repositories into one prioritized summary. Use when user says "check CI",
  "any PR updates", "what needs my attention", "dev status", or "what's blocking".
  Do NOT merge, close, or modify any PR or issue.
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: workflow
  tags: [ci, pr, github, status, dev-ops]
---

# Check CI Skill

One summary of everything that needs your dev attention.

## Instructions

### Step 1: Gather PR Status
Check all open PRs where you are author or reviewer. For each PR, get:
- Title and branch
- CI status (passing, failing, pending)
- Review status (approved, changes requested, awaiting review)
- How long it's been open

### Step 2: Check CI Failures
For any failing CI, identify:
- Which check failed (tests, lint, build, type check)
- Error summary (first failure message)
- Whether it's a flaky test or a real failure

### Step 3: Check Review Requests
List PRs where your review is requested, ordered by age (oldest first).

### Step 4: Check Assigned Issues
List issues assigned to you, grouped by priority labels.

### Step 5: Prioritize
- **BLOCKED** -- your PRs with failing CI or requested changes
- **ACTION NEEDED** -- review requests and assigned issues
- **WAITING** -- your PRs awaiting review from others
- **CLEAR** -- PRs with passing CI and approvals, ready to merge

### Step 6: Summary Line
End with a count: "X blocked, X need action, X waiting, X ready to merge"

## Output Format

**X blocked, X need action, X waiting, X ready to merge**

### BLOCKED (your PRs needing fixes)
| PR | Branch | Issue | Since |
|----|--------|-------|-------|

### ACTION NEEDED (reviews requested + assigned issues)
| Item | Type | Age | Action |
|------|------|-----|--------|

### WAITING (your PRs awaiting others)
| PR | Branch | CI | Reviewer | Waiting Since |
|----|--------|----|----------|---------------|

### READY TO MERGE
| PR | Branch | Approvals |
|----|--------|-----------|

## Rules
- NEVER merge, close, or modify any PR or issue
- NEVER push code or create commits
- Read-only -- observation and reporting only
- If CI data is unavailable, note it rather than guessing
- Flag PRs open longer than 3 days as "aging"
- Suggest next action for each blocked item
