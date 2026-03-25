---
name: check-calendar
description: >
  48-hour calendar lookahead with priority color-coding, conflict detection, and
  prep recommendations. Use when user says "check my calendar", "what do I have
  coming up", "any meetings tomorrow", or at 8am and 6pm daily.
  Do NOT modify, cancel, or create calendar events.
schedule: "daily 8am, daily 6pm"
allowed-tools: gws-calendar
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: productivity
  tags: [calendar, meetings, scheduling, productivity]
---

# Check Calendar Skill

48-hour lookahead so meetings never blindside you.

## Instructions

### Step 1: Pull Calendar
Fetch all events for the next 48 hours.
Use: `gws calendar events.list --params '{"calendarId": "primary", "timeMin": "NOW", "timeMax": "48H_LATER", "singleEvents": true, "orderBy": "startTime"}'`

### Step 2: List Events
For each event, show: time, title, attendees, location (virtual/physical), duration.

### Step 3: Priority Color-Code
- **Red (high-stakes)** -- external meetings, presentations, leadership meetings
- **Yellow (needs prep)** -- 1:1s, client calls, meetings with agendas
- **Green (routine)** -- recurring team check-ins, standups, optional meetings

### Step 4: Flag Issues
- Overlapping meetings (double-booked)
- Back-to-back with zero break (recommend which to join 5 min late)
- Location changes requiring travel time
- Meetings longer than 90 minutes (energy drain warning)
- Days with more than 5 hours total meeting time

### Step 5: Prep Actions
For each meeting, suggest one prep action:
- **1:1 with team member** -- "Review their last update or recent work"
- **External meeting** -- "Quick look at their company and recent news"
- **Presentation** -- "Confirm slides are ready, test screen share"
- **Recurring team meeting** -- "Check if there's an agenda -- if not, ask for one"

### Step 6: Energy Forecast
One-line forecast: "Tomorrow is heavy (6 hours of meetings) -- protect your evening" or "Light day tomorrow -- good time for deep work"

When calendar is clear, report "open road" status.

## Output Format

### Next 48 Hours -- [Date Range]

| Time | Event | Priority | Attendees | Prep Action |
|------|-------|----------|-----------|-------------|

### Flags
- [conflicts, back-to-backs, etc.]

### Energy Forecast
[one-line assessment]

## Rules
- NEVER modify, cancel, or create calendar events
- Read-only access only
- If a meeting has no agenda or description, flag it rather than guessing
- Always treat external meetings as high priority
- Suggest research and talking points for external meetings
