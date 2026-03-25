---
name: plan-week
description: >
  Pull calendar for the next 7 days, identify busy/open blocks, flag conflicts,
  and help set top 3 priorities. Use when user says "plan my week", "what does
  next week look like", "weekly planning", or every Sunday at 6pm.
  Do NOT modify, cancel, or create any calendar events.
schedule: "sunday 6pm"
allowed-tools: gws-calendar
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: productivity
  tags: [planning, calendar, weekly, productivity]
---

# Plan Week Skill

Start every week with a clear plan instead of scrambling on Monday morning.

## Instructions

### Step 1: Pull Calendar
Fetch all events for the next 7 days (Monday through Sunday).
Use: `gws calendar events.list --params '{"calendarId": "primary", "timeMin": "MONDAY_START", "timeMax": "SUNDAY_END", "singleEvents": true, "orderBy": "startTime"}'`

### Step 2: Summarize Each Day
For each day, report:
- Number of meetings
- Total meeting hours
- Largest open block for focused work

### Step 3: Identify Patterns
- Busiest day and lightest day
- Scheduling conflicts
- Back-to-back meetings with no break
- Days with more than 5 hours of meetings

### Step 4: Flag Prep Needed
List meetings that need preparation:
- External calls
- Presentations
- 1:1s with direct reports

### Step 5: Set Priorities
Ask the user to name their top 3 priorities for the week (three max).

### Step 6: Monday Focus
Highlight what specifically needs to happen Monday.

## Output Format

### Week of [Date] -- Overview

| Day | Meetings | Meeting Hours | Largest Open Block | Flags |
|-----|----------|---------------|-------------------|-------|

### Needs Prep
- [meeting] -- [what to prepare]

### Top 3 Priorities
1. [user sets these]
2.
3.

### Monday Focus
- [specific items for Monday]

### Energy Forecast
[one-line assessment: "Heavy week ahead -- protect Wednesday afternoon for deep work"]

## Rules
- NEVER modify, cancel, or create any calendar events
- Read-only access to calendar data
- If a meeting title is vague, flag as "unclear -- check the agenda"
- Keep the summary scannable -- no long paragraphs
- Keep tone encouraging -- Sunday evenings should feel organized, not stressful
