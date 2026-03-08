# Implementation Planning Skill

## Purpose
Decompose a feature request into a phased implementation plan with exact file paths, dependencies, and verification steps.

## When to Use
- Before starting any non-trivial feature
- When asked to plan implementation
- When `/plan` command is invoked

## Methodology

1. **Understand the Request** — Clarify ambiguities. Identify acceptance criteria.
2. **Research the Codebase** — Find related files, patterns, and conventions already in use.
3. **Identify Changes** — List every file that needs to be created or modified.
4. **Order by Dependency** — Phase changes so each phase is independently testable.
5. **Define Verification** — For each phase, specify how to verify it works.

## Output Format

### Requirements
- [bullet list of what this feature must do]

### Phase 1: [name]
**Files:**
- `path/to/file.ts` — [what changes]
- `path/to/test.ts` — [what tests]

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
