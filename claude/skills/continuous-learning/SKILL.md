---
name: learn
description: Extract reusable patterns from this session
allowed-tools: Read, Grep, Glob, Write
model: sonnet
user-invocable: true
---

# Continuous Learning Skill

Review this session and extract:

1. Error resolution patterns
2. User corrections and what was learned
3. Workarounds discovered
4. Project conventions identified
5. Effective debugging techniques

## Output Format

Each learned pattern saved as markdown:

```
# Pattern: [short name]

## Context
[When does this pattern apply?]

## Problem
[What problem does it solve?]

## Solution
[The approach that works]

## Confidence
[high/medium/low]

## Source
[Session date and brief context]
```

## Storage
Patterns saved to `~/.claude/agent-memory/learned/` as individual `.md` files.

## Rules
- Only extract patterns that are genuinely reusable
- Don't extract trivial or obvious things
- Include enough context that the pattern is useful without the original session
- Assign honest confidence levels
