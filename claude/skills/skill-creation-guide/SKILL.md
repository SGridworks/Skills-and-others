---
name: skill-creation-guide
description: >
  Interactive guide for creating new Claude Code skills following Anthropic's official
  skill specification. Use when user says "create a skill", "build a new skill",
  "make a skill", "skill template", "how to write a skill", or wants to package a
  workflow as a reusable skill. Do NOT use for modifying existing skills (just edit
  the SKILL.md directly) or for general coding tasks.
allowed-tools: Read, Grep, Glob, Edit, Write
model: inherit
user-invocable: true
arguments: skill idea (optional)
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: meta
  tags: [skill-creation, templates, workflows, meta]
---

# Skill Creation Guide

Create a new skill for: $ARGUMENTS

If no skill idea provided, ask what workflow the user wants to package.

## Instructions

Walk the user through each step. Do not skip steps. Validate each section before
moving to the next.

### Step 1: Define Use Cases

Ask the user to describe 2-3 concrete scenarios where this skill would be used.
Classify into one of three categories:

| Category | Description | Example |
|----------|-------------|---------|
| Document/Asset Creation | Creating consistent output (docs, code, designs) | frontend-design, report-generator |
| Workflow Automation | Multi-step processes with consistent methodology | sprint-planning, deploy-pipeline |
| MCP Enhancement | Workflow guidance on top of MCP tool access | sentry-code-review, linear-tasks |

### Step 2: Write the Frontmatter

Generate YAML frontmatter following these rules:

```yaml
---
name: kebab-case-name
description: >
  [What it does]. Use when user says "[trigger phrase 1]", "[trigger phrase 2]",
  "[trigger phrase 3]", or [broader trigger condition]. Do NOT use for [negative
  triggers to prevent over-firing].
allowed-tools: [only the tools this skill needs]
model: [sonnet|haiku|inherit]
user-invocable: true
arguments: [description of arguments, or omit if none]
compatibility: [environment requirements, if any]
license: MIT
metadata:
  author: [author name]
  version: 1.0.0
  category: [category]
  tags: [tag1, tag2, tag3]
---
```

**Critical rules for frontmatter:**
- `name`: kebab-case only, no spaces, no capitals, must match folder name
- `description`: MUST include WHAT it does + WHEN to use it (trigger phrases) + WHEN NOT to use it. Under 1024 characters. No XML angle brackets.
- `name` must NOT contain "claude" or "anthropic" (reserved)
- No README.md inside the skill folder

### Step 3: Write the Instructions

Structure the SKILL.md body with clear, numbered steps:

```markdown
# [Skill Name]

[Brief context or argument handling]

## Instructions

### Step 1: [First Major Step]
Clear explanation of what to do. Be specific and actionable.

### Step 2: [Second Major Step]
Include validation checks between steps if needed.

...continue steps...
```

**Best practices:**
- Be specific: "Run `python scripts/validate.py --input {filename}`" not "Validate the data"
- Put critical instructions at the top
- Use `## Important` or `## Critical` headers for must-follow rules
- Keep SKILL.md under 5,000 words
- Move detailed reference material to `references/` directory

### Step 4: Add Examples

Add 2-3 concrete examples showing how the skill handles real requests:

```markdown
## Examples

Example 1: [common scenario]
User says: "[exact phrase a user would type]"
Actions:
1. [what the skill does first]
2. [what it does next]
Result: [what the user gets]
```

### Step 5: Add Troubleshooting

Add 2-3 common error scenarios:

```markdown
## Troubleshooting

Error: [what went wrong]
Cause: [why it happened]
Solution: [how to fix it]
```

### Step 6: Add Rules

End with enforceable rules -- things that must always or never happen:

```markdown
## Rules
- [imperative statement about what to always/never do]
```

### Step 7: Create the Folder Structure

```
your-skill-name/
  SKILL.md              # Required -- main skill file
  scripts/              # Optional -- executable validation/helper scripts
  references/           # Optional -- detailed docs loaded on demand
  assets/               # Optional -- templates, fonts, icons
```

### Step 8: Validate

Before finalizing, check:
- [ ] SKILL.md is exactly `SKILL.md` (case-sensitive)
- [ ] Folder name matches the `name` field in frontmatter
- [ ] Folder name is kebab-case
- [ ] Description includes trigger phrases AND negative triggers
- [ ] Description is under 1024 characters
- [ ] No XML angle brackets anywhere
- [ ] Instructions are specific and actionable (no vague language)
- [ ] At least 2 examples included
- [ ] At least 2 troubleshooting entries included
- [ ] File is under 5,000 words

Run a trigger test by asking: "When would you use the [skill-name] skill?"
Claude will quote the description back. Adjust if the triggers are wrong.

## Progressive Disclosure

Skills use a 3-level loading system to minimize token usage:

| Level | What | When Loaded | Keep It |
|-------|------|-------------|---------|
| 1. Frontmatter | name + description | Always (system prompt) | Minimal -- just enough for trigger decisions |
| 2. SKILL.md body | Full instructions | When skill is triggered | Under 5,000 words |
| 3. references/ | Detailed docs, API guides | On demand when Claude needs them | As detailed as needed |

Consult `references/frontmatter-reference.md` for the complete field specification.
Consult `references/patterns.md` for common skill architecture patterns.

## Examples

Example 1: Create a deployment skill
User says: "Help me create a skill for deploying to production"
Actions:
1. Ask about deployment steps, environments, and tools
2. Classify as Workflow Automation
3. Generate frontmatter with deploy-related triggers
4. Write step-by-step deployment instructions
5. Add examples for staging vs production deploys
6. Add troubleshooting for common deploy failures
Result: Complete `deploy/SKILL.md` ready to install

Example 2: Create an MCP-enhanced skill
User says: "Create a skill that uses the Linear MCP for sprint planning"
Actions:
1. Ask about sprint planning workflow
2. Classify as MCP Enhancement
3. Generate frontmatter referencing Linear MCP tools
4. Write instructions that coordinate multiple MCP calls
5. Add examples showing sprint creation flow
Result: Complete `sprint-planner/SKILL.md` with MCP coordination

## Troubleshooting

Error: Skill won't trigger
Cause: Description is too vague or missing trigger phrases
Solution: Add specific phrases users would actually say. Test with "When would you use this skill?"

Error: Skill triggers too often
Cause: Description is too broad
Solution: Add negative triggers ("Do NOT use for...") and be more specific about scope

Error: Claude doesn't follow instructions
Cause: Instructions too verbose, buried, or ambiguous
Solution: Put critical instructions at the top. Use numbered steps. Be specific ("Run X" not "validate things")

## Rules
- Always validate frontmatter before creating the file
- Description MUST include both positive triggers and negative triggers
- Folder name MUST match the name field and use kebab-case
- SKILL.md MUST be exactly that casing -- no variations
- Never put a README.md inside a skill folder
- Keep SKILL.md under 5,000 words -- use references/ for detailed docs
