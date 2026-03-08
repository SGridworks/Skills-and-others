# Skill Architecture Patterns

Common patterns for structuring skills, from Anthropic's official guide.

## Pattern 1: Sequential Workflow Orchestration

Use when users need multi-step processes in a specific order.

```markdown
## Workflow: [Name]

### Step 1: [Action]
Call tool or perform action.
Parameters: [what's needed]

### Step 2: [Action]
Wait for: [dependency from Step 1]

### Step 3: [Action]
Parameters: [values from previous steps]
```

Key techniques:
- Explicit step ordering
- Dependencies between steps
- Validation at each stage
- Rollback instructions for failures

## Pattern 2: Multi-MCP Coordination

Use when workflows span multiple services.

```markdown
### Phase 1: [Service A]
1. Fetch data from Service A via MCP
2. Process and validate

### Phase 2: [Service B]
1. Use data from Phase 1
2. Create resources in Service B

### Phase 3: [Notification]
1. Notify via Service C
2. Include links from Phase 1 and 2
```

Key techniques:
- Clear phase separation
- Data passing between MCPs
- Validation before moving to next phase
- Centralized error handling

## Pattern 3: Iterative Refinement

Use when output quality improves with iteration.

```markdown
### Initial Draft
1. Generate first version
2. Save to temporary location

### Quality Check
1. Run validation script
2. Identify issues

### Refinement Loop
1. Address each issue
2. Regenerate affected sections
3. Re-validate
4. Repeat until quality threshold met

### Finalization
1. Apply final formatting
2. Generate summary
```

Key techniques:
- Explicit quality criteria
- Validation scripts for deterministic checks
- Know when to stop iterating (max iterations or quality threshold)

## Pattern 4: Context-Aware Tool Selection

Use when the same outcome requires different tools depending on context.

```markdown
### Decision Tree
1. Check context (file type, size, environment)
2. Select appropriate tool:
   - Condition A: Use Tool X
   - Condition B: Use Tool Y
   - Condition C: Use Tool Z

### Execute
Based on decision, call the appropriate tool.

### Explain
Tell the user why that tool was chosen.
```

Key techniques:
- Clear decision criteria
- Fallback options
- Transparency about choices

## Pattern 5: Domain-Specific Intelligence

Use when the skill adds specialized knowledge beyond tool access.

```markdown
### Pre-Check (Domain Rules)
1. Gather relevant data
2. Apply domain rules:
   - Rule 1: [domain constraint]
   - Rule 2: [domain constraint]
3. Document decision

### Execute (If Rules Pass)
Proceed with the action.

### Audit Trail
Log all decisions and rule evaluations.
```

Key techniques:
- Domain expertise embedded in logic
- Compliance/validation before action
- Comprehensive documentation
- Clear governance

## Anti-Patterns to Avoid

- **Too vague**: "Process the data" -- be specific about what tool and what format
- **Too verbose**: 10,000 words in SKILL.md -- move details to references/
- **No triggers**: Description says what but not when -- always include trigger phrases
- **No negative triggers**: Skill fires for everything remotely related
- **No examples**: Users and Claude don't know what good output looks like
- **Buried instructions**: Critical rules at the bottom -- put them at the top
