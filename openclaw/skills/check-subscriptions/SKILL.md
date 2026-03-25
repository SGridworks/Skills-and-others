---
name: check-subscriptions
description: >
  Scan email and bank statements for recurring charges, identify forgotten subscriptions,
  flag price increases, and recommend cancellations. Use when user says "check my
  subscriptions", "what am I paying for", "find recurring charges", or on the 1st of
  every month. Do NOT cancel, pause, or modify any subscription automatically.
schedule: "1st of month 9am"
allowed-tools: gws-gmail
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: personal-finance
  tags: [subscriptions, finance, email, recurring-charges]
---

# Check Subscriptions Skill

Scan for recurring charges and surface forgotten subscriptions.

## Instructions

### Step 1: Search Email for Receipts
Search the last 60 days of email for receipts, invoices, and payment confirmations.
Use: `gws gmail users.messages.list --params '{"userId": "me", "q": "subject:(receipt OR invoice OR subscription OR payment) newer_than:60d"}'`

### Step 2: Extract Charge Details
Read each matching email to extract: service name, amount, date, and billing frequency.

### Step 3: Check Pre-Exported Statements
If pre-exported bank statements or authorized integrations are available, cross-reference for recurring charges not found in email.

### Step 4: Build Subscription List
For each recurring charge, record:
- Service name
- Amount (converted to monthly equivalent)
- Actual billing cycle (monthly, annual, etc.)
- Last charge date

### Step 5: Categorize Usage
Classify each subscription as:
- **Actively using** -- used in the last 30 days
- **Rarely using** -- used sporadically
- **Forgotten** -- no usage in 30+ days
- **Free trial ending** -- trial about to convert to paid

### Step 6: Flag Anomalies
- Price increases compared to previous charges
- Annual renewals coming up in the next 30 days
- Unidentified merchants needing manual review

### Step 7: Calculate and Recommend
- Total monthly subscription spend
- Potential savings from cancelling "forgotten" subscriptions
- Recommend cancellations for forgotten category

## Output Format

### Subscription Report -- [Month Year]

| Category | Service | Monthly Cost | Billing Cycle | Last Charged | Status |
|----------|---------|-------------|---------------|--------------|--------|

### Summary
- Total monthly spend: $X
- Potential savings: $X/month
- Subscriptions flagged for review: N
- Annual renewals in next 30 days: N

## Rules
- NEVER cancel, pause, or modify any subscription automatically
- NEVER log into any banking portal or payment system
- Only use email data and pre-exported statements
- If unsure whether a charge is recurring, flag as "needs review"
- Convert all amounts to monthly for comparison, but show actual billing cycle
