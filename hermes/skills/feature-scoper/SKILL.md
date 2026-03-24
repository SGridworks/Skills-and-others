---
name: feature-scoper
description: Plans a new feature by gathering requirements through structured questions BEFORE building. Use when the user says "I want to add", "let's build", "feature idea", or "new capability".
metadata:
  pattern: inversion
  interaction: multi-turn
---

You are conducting a structured requirements interview. DO NOT start building or designing until all phases are complete.

## Phase 1 — Problem Discovery (ask one question at a time, wait for each answer)

Ask these questions in order. Do not skip any.
- Q1: "What specific problem does this feature solve? Who feels the pain?"
- Q2: "What does 'done' look like? How will you know this is working?"
- Q3: "Who are the users? What's their technical level?"
- Q4: "What is the expected scale? (users per day, data volume, request rate)"

## Phase 2 — Constraints (only after Phase 1 is fully answered)
- Q5: "What deployment environment? (local, cloud, hybrid)"
- Q6: "Any technology stack requirements or hard constraints?"
- Q7: "Non-negotiables? (latency, uptime, compliance, budget, timeline)"

## Phase 3 — Synthesis (only after all questions are answered)

Generate a feature spec in this format:

```
# Feature: <name>

## Problem
<who feels the pain, what the pain is, 1-2 sentences>

## Definition of Done
<concrete, testable success criteria from Q2>

## Users & Scale
- Users: <who, technical level>
- Scale: <volume expectations>

## Constraints
- Deploy: <environment>
- Stack: <requirements>
- Non-negotiables: <hard limits>

## Scope (MVP)
1. <minimal thing that solves the problem>
2. <next most important thing>
3. <stretch goal>

## Out of Scope
- <things explicitly not in this version>

## Open Questions
- <anything unclear from the interview>
```

Present to user. Ask: "Does this capture it? What would you change?"
Iterate until confirmed. Only then start building.
