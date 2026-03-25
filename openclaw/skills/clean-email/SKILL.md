---
name: clean-email
description: >
  Scan 60 days of inbox to identify email clutter -- newsletters never opened,
  marketing piling up, notifications always ignored. Recommend cleanup actions.
  Use when user says "clean my email", "inbox cleanup", "too many emails", or
  on the 1st of every month. Do NOT delete any email.
schedule: "1st of month 10am"
allowed-tools: gws-gmail
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: productivity
  tags: [email, inbox, cleanup, productivity]
---

# Clean Email Skill

Identify and remove email clutter without deleting anything important.

## Instructions

### Step 1: Search Inbox
Search the last 60 days of email, grouped by sender.
Use: `gws gmail users.messages.list --params '{"userId": "me", "q": "newer_than:60d"}'`

### Step 2: Categorize Senders
Identify all senders and categorize by type:
- Newsletter
- Marketing/promotional
- Notification (automated alerts)
- Transactional (receipts/confirmations)
- Personal/work correspondence

### Step 3: Analyze Engagement
For newsletters and marketing emails, analyze:
- Total emails from this sender in 60 days
- How many were opened (if tracking data available)
- Whether they're piling up unread

### Step 4: Group by Action Needed
- **Never opened** -- received 5+ emails, opened zero in 30+ days
- **Rarely opened** -- opened less than 20% of emails
- **Piling up** -- 10+ unread from this sender
- **Dead threads** -- conversations nobody replied to in 30+ days

If facing thousands of unread, prioritize the noisiest 20 senders first.

### Step 5: Calculate Impact
Estimate time savings: "Unsubscribing from these X senders would eliminate approximately Y emails per month"

### Step 6: Present Options
For each flagged sender, ask for a decision:
- Unsubscribe
- Archive all
- Create a filter
- Keep as-is

For suspicious senders, recommend blocking rather than unsubscribing.

## Output Format

### Inbox Cleanup Report -- [Date]

**Quick stats:** X unique senders, Y emails in 60 days, Z% unread

### Never Opened (recommended: unsubscribe)
| Sender | Emails (60d) | Opened | Action |
|--------|-------------|--------|--------|

### Rarely Opened (recommended: filter or unsubscribe)
| Sender | Emails (60d) | Open Rate | Action |
|--------|-------------|-----------|--------|

### Piling Up (recommended: archive + filter)
| Sender | Unread Count | Action |
|--------|-------------|--------|

### Estimated Savings
Cleaning up these senders would eliminate ~X emails/month

## Rules
- NEVER delete any email -- archive only, deletion is permanent
- NEVER unsubscribe from anything without explicit approval for that specific sender
- NEVER mark emails as read or move them without asking
- Present options and let the user decide -- recommend, don't act
- If a sender looks important (bank, employer, government), flag as "review carefully"
- Keep approach judgment-free -- no comments on subscription habits
