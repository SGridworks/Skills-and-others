---
name: dev-review-week
description: >
  Generate a developer weekly summary of commits, PRs merged, issues closed,
  code review activity, and patterns. Saves as a dated markdown artifact.
  Use when user says "review my dev week", "what did I ship", "weekly dev
  retrospective", or "summarize my week". Do NOT modify any git history,
  issues, or PRs.
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: workflow
  tags: [review, retrospective, weekly, productivity]
---

# Dev Review Week Skill

Friday summary that makes performance reviews easy.

## Instructions

### Step 1: Gather Week's Activity
Collect data from Monday through Friday:
- Commits authored (from `git log --since` across repos)
- PRs opened, reviewed, and merged
- Issues opened and closed
- Code review comments given and received

### Step 2: Summarize Accomplishments
- **SHIPPED** -- PRs merged and issues closed
- **IN PROGRESS** -- PRs still open, issues started
- **REVIEWED** -- code reviews completed for others
- **DECISIONS** -- architectural or technical decisions made

### Step 3: Spot Patterns
One observation about the week:
- Lines changed, files touched
- Ratio of feature work vs bug fixes vs reviews
- Comparison to previous weeks if data available
- "You merged 4 PRs this week -- 2 more than average"

### Step 4: Next Week Preview
- Top carry-over items
- Known deadlines or milestones
- Blocked items needing attention

### Step 5: Save Artifact
Save as `dev-week-YYYY-MM-DD.md` to a reviews directory.

## Output Format

### Dev Week Review -- [Date Range]

#### Shipped
- [PR title] -- merged [date], [brief description]

#### In Progress
- [PR/issue] -- [status, what's left]

#### Reviews Given
- [PR title] -- [approved/changes requested]

#### Decisions Made
- [decision and context]

#### Patterns
- [observation about the week]

#### Next Week
- [carry-over items and priorities]

**Stats: X commits, X PRs merged, X issues closed, X reviews given**

## Rules
- NEVER modify git history, issues, or PRs
- Read-only -- observation and reporting only
- Keep the summary factual -- observations, not judgments
- Each review should be standalone -- readable without previous context
- Under 2 minutes to read
- If data is sparse, note it honestly
