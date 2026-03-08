---
name: plan
description: >
  Decompose feature requests into phased implementation plans with exact file paths,
  dependencies, and verification steps. Use when user says "plan this feature",
  "how should I implement", "break this down", "create an implementation plan",
  "design the architecture", or asks for a structured approach before coding.
  Do NOT use for simple one-file changes or bug fixes that don't need planning.
allowed-tools: Read, Grep, Glob, WebSearch, WebFetch
model: sonnet
user-invocable: true
arguments: description
license: MIT
metadata:
  author: SGridworks
  version: 2.0.0
  category: workflow
  tags: [planning, architecture, design, implementation]
---

# Implementation Planning Skill

Create a detailed, phased plan for: $ARGUMENTS

## Instructions

### Step 1: Understand the Request
Clarify ambiguities. Identify acceptance criteria. Ask questions if requirements are unclear.

### Step 2: Research the Codebase
Use Glob, Grep, and Read to find related files, patterns, and conventions already in use. Never plan changes to files you haven't read.

### Step 3: Identify All Changes
List every file that needs to be created or modified, with specific descriptions of what changes.

### Step 4: Order by Dependency
Phase changes so each phase is independently testable and deployable. Earlier phases should not depend on later ones.

### Step 5: Define Verification
For each phase, specify exactly how to verify it works -- specific commands, test files, or manual checks.

## Output Format

### Requirements
- [bullet list of what this feature must do]

### Phase 1: [name]
**Files:**
- `path/to/file.ts` -- [what changes]
- `path/to/test.ts` -- [what tests]

**Verification:**
- [ ] [specific command or check to verify this phase]

### Phase 2: [name]
...

### Risks
- [potential issues and mitigations]

### Out of Scope
- [what this plan deliberately does NOT cover]

## Examples

Example 1: Plan a new API endpoint
User says: "Plan how to add a user preferences API"
Actions:
1. Research existing API patterns (routes, controllers, middleware)
2. Identify model, route, controller, test, and migration files
3. Phase: model first, then route + controller, then tests, then docs
Result: 4-phase plan with 8 files, verification commands per phase

Example 2: Plan a refactor
User says: "Plan how to extract the auth logic into a shared module"
Actions:
1. Find all files importing auth-related code
2. Map dependencies between auth consumers
3. Phase: create shared module, migrate consumers one at a time, remove old code
Result: Phased migration plan with rollback steps at each phase

## Troubleshooting

Error: Plan is too vague
Cause: Didn't read the codebase before planning
Solution: Always use Glob/Grep/Read to understand existing patterns first

Error: Phases have circular dependencies
Cause: Changes not properly ordered
Solution: Identify the dependency graph and break cycles by introducing interfaces

## Rules
- Always research the codebase before planning
- Never plan changes to files you haven't read
- Each phase must be independently deployable
- Include test files in every phase
- Call out risks and unknowns explicitly
