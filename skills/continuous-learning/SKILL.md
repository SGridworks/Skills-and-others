# Continuous Learning Skill

## Purpose
Extract reusable patterns from the current session and persist them as learned instincts.

## When to Use
- At the end of productive sessions (10+ messages)
- When `/learn` command is invoked
- When a novel problem-solving pattern emerges

## What to Extract

1. **Error Resolution Patterns** — How specific errors were diagnosed and fixed
2. **User Corrections** — When the user corrected the approach, what was learned
3. **Workarounds** — Non-obvious solutions to environment or tooling issues
4. **Project Conventions** — Patterns specific to this codebase
5. **Debugging Techniques** — Effective diagnostic approaches

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
Patterns saved to `~/.claude/skills/learned/` as individual `.md` files.

## Rules
- Only extract patterns that are genuinely reusable
- Don't extract trivial or obvious things
- Include enough context that the pattern is useful without the original session
- Assign honest confidence levels
