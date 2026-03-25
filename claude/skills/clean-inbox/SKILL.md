---
name: clean-inbox
description: >
  Triage GitHub notifications, stale branches, old PRs, and abandoned issues.
  Identify what needs attention vs what can be cleaned up. Use when user says
  "clean my dev inbox", "triage notifications", "stale branches", or "clean up
  old PRs". Do NOT delete branches, close PRs, or close issues without approval.
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: workflow
  tags: [cleanup, notifications, branches, triage]
---

# Clean Dev Inbox Skill

Reclaim your dev inbox in one pass.

## Instructions

### Step 1: Check Stale Branches
Find branches with no commits in 30+ days. Categorize:
- **Merged** -- branch was merged, safe to delete
- **Abandoned** -- no recent commits, no open PR
- **Active** -- has recent activity or an open PR

### Step 2: Check Old PRs
Find PRs open longer than 14 days:
- **Stale** -- no activity in 14+ days
- **Blocked** -- waiting on review or CI
- **Draft** -- still in draft, may be forgotten

### Step 3: Check Abandoned Issues
Find assigned issues with no recent comments or linked PRs:
- **Stale** -- no activity in 30+ days
- **Blocked** -- has a blocker label or comment
- **Orphaned** -- assignee no longer active

### Step 4: Calculate Cleanup Impact
"Cleaning up X stale branches and Y old PRs would reduce noise by Z%"

### Step 5: Present Options
For each item, recommend an action and wait for approval:
- Delete branch
- Close PR (with comment)
- Reassign issue
- Keep as-is

## Output Format

### Dev Inbox Cleanup -- [Date]

**Quick stats:** X stale branches, Y old PRs, Z stale issues

### Stale Branches (safe to delete)
| Branch | Last Commit | Merged? | Action |
|--------|-------------|---------|--------|

### Old PRs
| PR | Author | Open Since | Status | Action |
|----|--------|------------|--------|--------|

### Stale Issues
| Issue | Assignee | Last Activity | Action |
|-------|----------|---------------|--------|

### Estimated Cleanup
Removing X branches and closing Y PRs reduces active items by Z%

## Rules
- NEVER delete branches, close PRs, or close issues without explicit approval
- NEVER force-push or modify git history
- Present options and let the user decide
- If a branch or PR looks like active work, flag as "verify before cleaning"
- Always check if a branch has been merged before recommending deletion
- Recommend closing with a comment rather than silent closure
