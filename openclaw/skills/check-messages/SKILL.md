---
name: check-messages
description: >
  Aggregate unread messages across Slack, Discord, Telegram, WhatsApp, and other
  platforms into one prioritized summary. Use when user says "check my messages",
  "any messages", "what did I miss", or at 9am, 12pm, 3pm, 6pm daily.
  Do NOT reply to any message on behalf of the user.
schedule: "daily 9am, daily 12pm, daily 3pm, daily 6pm"
allowed-tools: messaging-skills
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: productivity
  tags: [messages, slack, discord, telegram, notifications]
---

# Check Messages Skill

One prioritized summary instead of checking six different apps.

## Instructions

### Step 1: Scan All Platforms
Check unread messages across all connected channels: Slack, Discord, Telegram, WhatsApp, iMessage, and any other active platforms. Only check platforms with available skills.

### Step 2: Assess Priority
For each unread message:
- **URGENT (red)** -- someone waiting on a response now, time-sensitive, from boss/key clients/family, contains "urgent"/"ASAP"/"help"
- **IMPORTANT (yellow)** -- active conversations, assigned tasks, direct mentions, close collaborators
- **FYI (green)** -- announcements, group chat chatter, news/updates
- **SKIP (gray)** -- automated notifications, muted channels, old messages in fast-moving chats

### Step 3: Deliver Summary
Organize by priority level. For each message include: sender, platform, one-line preview, and suggested action (reply, snooze, mark read, open in app).

If 200+ unreads, summarize rather than list everything.

## Output Format

### Messages -- [Time]

**X urgent, X important, X FYI, X skipped**

### URGENT
| Sender | Platform | Preview | Action |
|--------|----------|---------|--------|

### IMPORTANT
| Sender | Platform | Preview | Action |
|--------|----------|---------|--------|

### FYI
| Sender | Platform | Preview | Action |
|--------|----------|---------|--------|

## Rules
- NEVER reply to any message on behalf of the user
- NEVER mark messages as read
- Respect do-not-disturb settings -- skip muted channels unless urgent
- If unsure about priority, round up (flag as important rather than FYI)
- Keep previews to one line
- Learn which channels matter vs. noise over time
