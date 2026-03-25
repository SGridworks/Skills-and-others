---
name: review-week
description: >
  Generate a weekly summary of accomplishments, decisions, blockers, and patterns
  from calendar and task data. Saves as a dated markdown file. Use when user says
  "review my week", "what did I do this week", "weekly retrospective", or every
  Friday at 5pm. Do NOT modify any tasks, events, or goals.
schedule: "friday 5pm"
allowed-tools: gws-calendar
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: productivity
  tags: [review, retrospective, weekly, productivity]
---

# Review Week Skill

Friday reflection that makes quarterly reviews easy.

## Instructions

### Step 1: Pull Week's Data
Fetch all calendar events from Monday through Friday.
Use: `gws calendar events.list --params '{"calendarId": "primary", "timeMin": "MONDAY_START", "timeMax": "FRIDAY_END", "singleEvents": true, "orderBy": "startTime"}'`

Also check: completed tasks and goal progress if available.

### Step 2: Analyze Meetings
Break down by type: 1:1s, group syncs, external meetings. Note attendees and topics.

### Step 3: Generate Summary Sections
- **HIGHLIGHTS** -- 3-5 most meaningful accomplishments or progress
- **DECISIONS MADE** -- key decisions from meetings and completed tasks
- **BLOCKERS** -- anything that slowed progress or remains unresolved
- **NEXT WEEK PREVIEW** -- top 3 priorities and key upcoming meetings
- **PATTERNS** -- one observation about time allocation ("22 hours of meetings this week -- 6 more than last week")

### Step 4: Save Artifact
Save as a dated markdown file: `week-of-YYYY-MM-DD.md` to `~/Documents/reviews/` or user-specified location.

### Step 5: Spot Trends
If past weekly reviews are available, compare to spot trends (e.g., "meetings have increased 3 weeks in a row").

## Output Format

### Week of [Date] -- Review

#### Highlights
1. [accomplishment]
2. [accomplishment]
3. [accomplishment]

#### Decisions Made
- [decision and context]

#### Blockers
- [blocker and status]

#### Next Week Preview
1. [priority]
2. [priority]
3. [priority]

#### Patterns
- [observation about time/work patterns]

**Meeting hours this week: X | Last week: Y**

## Rules
- Read-only access to calendar and tasks
- NEVER modify any tasks, events, or goals
- If data is sparse, note it honestly without judgment
- Keep the summary factual -- observations, not opinions about productivity
- Each weekly review should be standalone -- readable without previous context
- Under 2 minutes to read, fits on one page
