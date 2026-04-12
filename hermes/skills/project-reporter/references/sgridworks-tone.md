# SGridWorks Voice & Tone Guide

## Core Voice

**Direct. First-principles. No corporate platitudes.**

We speak like engineers who ship. Every sentence earns its place.

## Writing Principles

### 1. Short Sentences
Use periods. Break complex thoughts. One idea per sentence.

**No:** "We are currently in the process of evaluating various potential solutions to the problem we identified."  
**Yes:** "We're testing three solutions. Problem: API latency spiked to 2s."

### 2. Evidence With Claims
Every claim needs proof. Metrics, dates, or observable facts.

**No:** "The launch went well."  
**Yes:** "Launch hit 99.9% uptime. 340 signups in 24 hours."

### 3. Lead With Action
Start with the verb. What happened? What's next?

**No:** "There was a discussion about the roadmap."  
**Yes:** "Shipped roadmap v2. Cut three features. Added auth."

### 4. Fail Forward
Problems are data. Share blockers honestly. State mitigations clearly.

**No:** "We're experiencing some minor delays due to unforeseen circumstances."  
**Yes:** "Delay: vendor API broke contract. Mitigation: built wrapper, shipping Friday."

### 5. No Filler
Cut these:
- "Very," "really," "quite," "rather"
- "We believe," "we think," "it seems"
- "Leverage," "synergy," "optimize," "strategic"
- Explanations for the obvious

## Design Note
No blue-purple gradients. Clean. Sharp. Monochrome or bold single colors.

## Examples

### Bad
> "We are very excited to announce that we have made significant progress on our core infrastructure initiatives this quarter, and we believe this will position us well for future growth opportunities moving forward."

### Good
> "Infrastructure shipped:
> - Cut deploy time 40% (8 min → 5 min)
> - Migrated 3 services to K8s
> - Zero downtime during switch"

### Bad
> "There were some challenges encountered with the third-party integration that we are currently working through with the vendor."

### Good
> "Blocker: Stripe webhook dropped 12% of events.  
> Fix: Retry logic + idempotency keys. Testing now.  
> ETA: Wednesday."

## Quick Check
Before publishing, ask:
1. Can I cut this sentence in half?
2. Where's the evidence?
3. Does it start with a verb?
4. Would I say this to a teammate at a whiteboard?
