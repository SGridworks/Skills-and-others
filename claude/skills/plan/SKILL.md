---
name: plan
description: Phased implementation planning with file paths and verification
allowed-tools: Read, Grep, Glob, WebSearch, WebFetch
model: sonnet
user-invocable: true
arguments: description
---

# Implementation Planning Skill

Create a detailed, phased plan for: $ARGUMENTS

Research the codebase first. Identify all files that need changes. Order phases by dependency. Include verification steps for each phase. Call out risks and unknowns.

## Output Format

### Requirements
- [bullet list of what this feature must do]

### Phase 1: [name]
**Files:**
- `path/to/file.ts` -- [what changes]
- `path/to/test.ts` -- [what tests]

**Verification:**
- [ ] [how to verify this phase works]

### Phase 2: [name]
...

### Risks
- [potential issues and mitigations]

### Out of Scope
- [what this plan deliberately does NOT cover]

## Rules
- Always research the codebase before planning
- Never plan changes to files you haven't read
- Each phase must be independently deployable
- Include test files in every phase
- Call out risks and unknowns explicitly
