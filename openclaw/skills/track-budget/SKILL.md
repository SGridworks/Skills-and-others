---
name: track-budget
description: >
  Analyze email receipts and bank notifications for weekly spending visibility.
  Categorize spending, compare against budget targets, flag overspending. Use when
  user says "track my spending", "budget check", "where is my money going", or every
  Friday at 6pm. Do NOT access bank accounts or financial institutions directly.
schedule: "friday 6pm"
allowed-tools: gws-gmail
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: personal-finance
  tags: [budget, spending, finance, email, tracking]
---

# Track Budget Skill

Weekly spending snapshot from email receipts and notifications.

## Instructions

### Step 1: Search Email for Transactions
Search the past 7 days of email for purchase receipts, order confirmations, bank alerts, and payment notifications.
Use: `gws gmail users.messages.list --params '{"userId": "me", "q": "subject:(receipt OR order OR confirmation OR transaction OR purchase) newer_than:7d"}'`

### Step 2: Extract Transaction Details
Read each email to pull: amount, merchant, date, and any item descriptions.

### Step 3: Categorize Spending
Assign each transaction to a category:
- Groceries
- Dining/takeout
- Transportation
- Subscriptions
- Shopping
- Entertainment
- Bills
- Other

### Step 4: Compare Against Budget
Use these defaults (or user-provided targets):
- Groceries: $400/month (~$100/week)
- Dining out: $200/month (~$50/week)
- Subscriptions: $100/month
- Shopping: $150/month (~$37/week)

Calculate weekly spending, monthly pace, and budget remaining per category.

### Step 5: Flag Overspending
Flag any category where the monthly pace will exceed the budget target.

### Step 6: Observations
Provide 1-2 brief, non-judgmental observations about spending patterns.

## Output Format

### Weekly Spending -- [Date Range]

| Category | This Week | Month to Date | Monthly Budget | Status |
|----------|-----------|---------------|----------------|--------|

**Weekly Total: $X | Monthly Pace: $X | Monthly Budget: $X**

### Observations
- [1-2 brief patterns noticed]

### Flagged
- [categories trending over budget]

## Rules
- NEVER access bank accounts, credit cards, or financial institutions directly
- NEVER ask for bank login credentials
- Only use email data -- receipts, confirmations, and transaction alerts
- Never judge or shame spending habits -- keep tone friendly and non-judgmental
- If a transaction is ambiguous, categorize as "other" and flag for manual review
- If the user shares actual budget numbers, use those instead of defaults
- If data is sparse, let the user know and suggest manually adding transactions
