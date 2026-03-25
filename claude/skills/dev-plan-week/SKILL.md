---
name: dev-plan-week
description: >
  Pull GitHub issues, PRs, and project board data to create a prioritized
  developer week plan. Use when user says "plan my dev week", "what should I
  work on", "sprint planning", or "prioritize my backlog". Do NOT create,
  close, or modify any issues or PRs.
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: workflow
  tags: [planning, sprint, backlog, productivity]
---

# Dev Plan Week Skill

Start the dev week knowing exactly what matters.

## Instructions

### Step 1: Gather Open Work
Pull all work items assigned to the user:
- Open PRs (authored and reviewing)
- Assigned issues (by priority label)
- Any items from project boards

### Step 2: Assess Carryover
Identify work from last week that's still open:
- PRs still in review
- Issues started but not completed
- Stale branches with recent commits

### Step 3: Prioritize
Group work into:
- **Must do** -- blocking others, deadline-driven, or P0/P1 labeled
- **Should do** -- important but not urgent, assigned issues
- **Could do** -- nice-to-have, tech debt, improvements
- **Delegate/defer** -- can wait or should be reassigned

### Step 4: Estimate Capacity
Based on the number of items and their complexity:
- Flag if the week looks overloaded (more than 5 must-do items)
- Identify the lightest day for deep coding work
- Recommend which items to defer if overloaded

### Step 5: Set Top 3
Ask the user to confirm their top 3 priorities for the week.

### Step 6: Monday Focus
Identify what specifically should happen Monday to unblock the rest of the week.

## Output Format

### Dev Week Plan -- [Date Range]

#### Carryover from Last Week
- [items still open]

#### Must Do
| Item | Type | Priority | Blocked By |
|------|------|----------|------------|

#### Should Do
| Item | Type | Priority |
|------|------|----------|

#### Could Do
| Item | Type |
|------|------|

#### Top 3 Priorities
1. [user confirms]
2.
3.

#### Monday Focus
- [specific unblocking actions]

#### Capacity Check
[overloaded/balanced/light -- with recommendation]

## Rules
- NEVER create, close, or modify any issues or PRs
- Read-only -- planning and reporting only
- If priority labels are missing, infer from context and flag for confirmation
- Keep the plan realistic -- better to do 3 things well than 10 things poorly
- Flag dependencies between items
