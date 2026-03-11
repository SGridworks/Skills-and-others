---
name: learn
description: >
  Extract reusable patterns, debugging techniques, and project conventions from the
  current session and persist them for future use. Use when user says "what did we
  learn", "save this pattern", "extract learnings", "remember this", "session
  retrospective", or at the end of a productive session (10+ messages). Do NOT use
  during active development, for saving temporary task state, or for remembering
  things already in CLAUDE.md -- wait until a natural stopping point or when
  explicitly asked.
allowed-tools: Read, Grep, Glob, Write
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 2.0.0
  category: workflow
  tags: [learning, patterns, memory, retrospective]
---

# Continuous Learning Skill

Review this session and extract reusable patterns.

## Instructions

### Step 1: Review Session
Scan the conversation for moments where:
- An error was diagnosed and fixed
- The user corrected the approach
- A non-obvious workaround was discovered
- A project convention was established
- An effective debugging technique was used

### Step 2: Check for Duplicates
Read existing patterns in `~/.claude/agent-memory/learned/` before writing. If a similar pattern exists, update its confidence level or add new context rather than creating a duplicate.

### Step 3: Evaluate Each Pattern
For each candidate pattern, ask:
- Is this genuinely reusable in future sessions?
- Is it non-obvious enough to be worth saving?
- Does it have enough context to be useful standalone?
- Does it already exist in CLAUDE.md or the learned patterns directory?

### Step 4: Format and Save
Write each pattern as a markdown file to `~/.claude/agent-memory/learned/`.
After saving, output a summary of what was saved (pattern names + confidence levels).

## Output Format

Each learned pattern saved as markdown:

```markdown
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

## Examples

Example 1: Error resolution pattern
User fixed a cryptic build error during the session.
Pattern extracted:
- Name: "pyo3 cffi backend missing"
- Context: Python projects using cryptography on minimal Linux images
- Problem: `ModuleNotFoundError: No module named '_cffi_backend'`
- Solution: `pip install cffi` before installing cryptography
- Confidence: high

Example 2: Project convention
User corrected the approach to use a specific pattern.
Pattern extracted:
- Name: "API routes use kebab-case"
- Context: This project's REST API naming convention
- Problem: Created route as `/getUserProfile`
- Solution: Use `/get-user-profile` -- all routes are kebab-case
- Confidence: high

## Troubleshooting

Error: No patterns found
Cause: Session was too short or straightforward
Solution: Only extract patterns from sessions with 10+ messages and non-trivial work

Error: Pattern already exists
Cause: Similar pattern was saved in a previous session
Solution: Update the existing pattern's confidence level instead of creating a duplicate

## Rules
- Only extract patterns that are genuinely reusable
- Don't extract trivial or obvious things
- Include enough context that the pattern is useful without the original session
- Assign honest confidence levels
- Use kebab-case filenames for saved patterns
