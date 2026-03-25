---
name: track-packages
description: >
  Monitor email for shipping confirmations and tracking updates from all carriers.
  Consolidate pending, in-transit, and delivered packages into one view. Use when
  user says "where are my packages", "track my orders", "any deliveries today",
  or at 8am and 5pm daily. Do NOT interact with any retailer or carrier.
schedule: "daily 8am, daily 5pm"
allowed-tools: gws-gmail
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: personal
  tags: [packages, shipping, tracking, delivery]
---

# Track Packages Skill

All shipments in one place.

## Instructions

### Step 1: Search Email for Shipping Updates
Search the last 30 days for shipping confirmations, tracking updates, and delivery notifications.
Use: `gws gmail users.messages.list --params '{"userId": "me", "q": "subject:(shipped OR tracking OR delivery OR out for delivery) newer_than:30d"}'`

### Step 2: Extract Package Details
Read each email to pull: tracking number, carrier, expected delivery date, and item description.

### Step 3: Build Consolidated List
For each package, record:
- Retailer/sender name
- Item description (if available)
- Carrier and tracking number
- Current status
- Expected delivery date
- Direct tracking link

### Step 4: Categorize by Status
- **Arriving today** -- out for delivery or delivery date is today
- **In transit** -- on the way, no issues
- **Delayed** -- past original delivery date
- **Problem** -- carrier flagged an issue
- **Delivered** -- within last 48 hours
- **Stuck** -- label created but no movement in 5+ days

### Step 5: Morning vs Evening
- **Morning runs** -- show full board
- **Evening runs** -- show only changes since morning

### Step 6: Flag Attention Items
Highlight delays, problems, and packages that seem lost.

## Output Format

### Package Tracker -- [Date, Time]

**X arriving today, X in transit, X delivered this week**

### Arriving Today
| Retailer | Item | Carrier | Tracking | ETA |
|----------|------|---------|----------|-----|

### In Transit
| Retailer | Item | Carrier | Tracking | ETA |
|----------|------|---------|----------|-----|

### Needs Attention
| Retailer | Item | Status | Details |
|----------|------|--------|---------|

### Recently Delivered
| Retailer | Item | Delivered |
|----------|------|-----------|

## Rules
- NEVER sign for packages, authorize redirects, or change delivery instructions
- NEVER interact with any retailer or carrier
- Read-only email access -- observation and reporting only
- If tracking info is unclear or missing, show what's available and note "tracking details limited"
- Include tracking links for click-through to real-time updates
