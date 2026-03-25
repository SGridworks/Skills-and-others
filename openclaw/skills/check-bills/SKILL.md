---
name: check-bills
description: >
  Scan email for upcoming bills, organize by urgency, catch price increases and
  duplicate charges. Use when user says "check my bills", "what bills are due",
  "any payments coming up", or every Monday at 8am. Do NOT pay, authorize, or
  schedule any payment.
schedule: "monday 8am"
allowed-tools: gws-gmail
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: personal-finance
  tags: [bills, payments, finance, email]
---

# Check Bills Skill

Scan email for upcoming bills and flag anything due soon.

## Instructions

### Step 1: Search Email for Bills
Search the last 45 days of email for bills, invoices, payment reminders, and utility statements.
Use: `gws gmail users.messages.list --params '{"userId": "me", "q": "subject:(bill OR invoice OR statement OR payment due OR reminder) newer_than:45d"}'`

### Step 2: Extract Bill Details
Read each matching email to pull: biller name, amount owed, due date, and autopay status.

### Step 3: Organize by Urgency
Group every bill into:
- **OVERDUE** -- past due date
- **DUE THIS WEEK** -- due in next 7 days
- **COMING UP** -- due in next 30 days
- **AUTOPAY** -- scheduled to pay automatically

### Step 4: Flag Anomalies
- Price increases compared to last month
- New companies billing you for the first time
- Bills that normally appear but are missing this month
- Late fees or penalties
- Bills due within 3 days without autopay

## Output Format

**Summary: X bills due this week, X overdue, total: $X,XXX**

### OVERDUE
| Company | Amount | Due Date | Autopay |
|---------|--------|----------|---------|

### DUE THIS WEEK
| Company | Amount | Due Date | Autopay |
|---------|--------|----------|---------|

### COMING UP
| Company | Amount | Due Date | Autopay |
|---------|--------|----------|---------|

### AUTOPAY
| Company | Amount | Due Date |
|---------|--------|----------|

### Flags
- [anomalies listed here]

## Rules
- NEVER pay, authorize, or schedule any payment
- NEVER log into any billing portal
- Only store last 4 digits of any account numbers
- Read-only access to email -- do not send anything
- When in doubt about a due date, flag as "verify manually"
