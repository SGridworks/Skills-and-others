---
name: autoresearch
description: >
  Iteratively improve a Claude Code skill using Karpathy's autoresearch loop.
  Defines yes/no evaluation criteria, runs the skill against test prompts,
  scores output, makes one change, re-scores, keeps improvements, discards regressions.
  Use when asked to "improve a skill", "optimize a skill", "autoresearch", or
  "make this skill better". Inspired by Karpathy's autoresearch + Ole Lehmann's adaptation.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Agent, AskUserQuestion
user-invocable: true
metadata:
  author: SGridworks
  version: 1.0.0
  category: meta
  tags: [autoresearch, skill-improvement, prompt-optimization, karpathy]
---

# Autoresearch: Iterative Skill Improvement

Adapt Karpathy's autoresearch loop to Claude Code skills. The core principle:
**one change, one measurement, keep or discard, repeat.**

## Architecture

Three components, mirroring autoresearch:

| Component | Autoresearch (ML) | This Skill (Prompts) |
|-----------|-------------------|---------------------|
| Instructions | `program.md` | This file (immutable) |
| Fixed evaluator | `prepare.py` | Yes/no checklist (locked after setup) |
| Mutable target | `train.py` | Target skill's SKILL.md or skill.md |
| Metric | `val_bpb` (lower = better) | Pass rate % (higher = better) |
| Experiment | 5-min training run | Run skill against test prompts |

## Constraints

- **Only modify the target skill file.** Never modify the evaluation criteria mid-loop.
- **One change per iteration.** Never bundle multiple changes.
- **Keep or discard immediately.** If pass rate improves or stays the same with qualitative improvement, keep. If it drops, discard (revert the edit).
- **Never stop until told to or until 3 consecutive no-improvement iterations.**
- **Log everything** to `~/.claude/autoresearch/sessions/`.

---

## Phase 0: Setup

### 0a. Identify the target skill

Ask the user which skill to improve, or accept it as an argument (e.g., `/autoresearch investigate`).

Find the skill file:
```bash
# Check both patterns
ls ~/.claude/skills/<skill-name>/SKILL.md ~/.claude/skills/<skill-name>/skill.md 2>/dev/null
```

Read the skill file completely. This is the **mutable target** -- the only file the loop will edit.

### 0b. Understand what the skill does

Read the skill file and summarize in 1-2 sentences what the skill is supposed to accomplish. Present this to the user for confirmation.

### 0c. Define test prompts

Ask the user: **"What are 2-3 realistic scenarios where you'd invoke this skill?"**

These become the test prompts. They should represent real usage, not edge cases. Store them as a list.

If the user doesn't have specific scenarios, propose 3 based on the skill's description and ask for approval.

### 0d. Define evaluation criteria

Ask the user: **"What does 'good' look like? I'll help you turn your answer into 3-6 yes/no questions."**

Guide the user through defining binary evaluation questions. Rules for good criteria:
- Each question checks exactly ONE thing
- Answer must be unambiguous yes or no
- 3-6 questions total (sweet spot)
- Questions should be about the OUTPUT, not the process

**Examples of good criteria:**
- "Does the output include a specific, actionable recommendation?"
- "Is the response under 500 words?"
- "Does it reference the actual code (file paths, function names)?"
- "Does it avoid generic advice that could apply to any project?"

**Examples of bad criteria:**
- "Is it good?" (subjective, not binary)
- "Does it use the right tone?" (vague)
- "Is it comprehensive AND concise?" (two things in one)

Once agreed, these criteria are **LOCKED**. They will not change during the loop.

### 0e. Create session directory and baseline

```bash
SESSION_ID=$(date +%Y%m%d-%H%M%S)
SESSION_DIR=~/.claude/autoresearch/sessions/$SESSION_ID
mkdir -p "$SESSION_DIR"
```

Write the session config:
```bash
cat > "$SESSION_DIR/config.json" << 'SESSIONEOF'
{
  "skill": "<skill-name>",
  "skill_file": "<path-to-skill-file>",
  "test_prompts": [
    "<prompt-1>",
    "<prompt-2>",
    "<prompt-3>"
  ],
  "criteria": [
    "<criterion-1>",
    "<criterion-2>",
    "<criterion-3>"
  ],
  "created": "<timestamp>"
}
SESSIONEOF
```

Save a backup of the original skill file:
```bash
cp <skill-file> "$SESSION_DIR/original.md"
```

---

## Phase 1: Baseline Measurement

Run the skill mentally against each test prompt. For each prompt, evaluate against all criteria.

**Evaluation method:** Read the skill file and simulate what output it would produce for each test prompt. Score each criterion as PASS (1) or FAIL (0).

Record results in `$SESSION_DIR/results.tsv`:
```
iteration	prompt	criterion	pass	total_score	change_description	decision
0	baseline	-	-	<score>/<total>	original skill	baseline
```

Report the baseline to the user:
```
BASELINE: <X>/<Y> (<Z>%) pass rate
  Prompt 1: <score>
  Prompt 2: <score>
  Prompt 3: <score>
```

---

## Phase 2: The Loop

### For each iteration:

**Step 1: Analyze weaknesses.**
Look at which criteria are failing and for which prompts. Identify the single most impactful weakness.

**Step 2: Propose ONE change.**
Formulate a single, specific edit to the skill file that addresses the identified weakness. Changes can be:
- Adding a specific instruction
- Rewording an ambiguous section
- Adding an example
- Restructuring the flow
- Removing a conflicting instruction
- Adding a constraint or guardrail

Present the proposed change to the user: "Iteration N: I want to [change description]. This targets [criterion X] which is failing on [prompt Y]."

Wait for user approval before proceeding. If the user says "auto" or "just run it", proceed without asking for the remaining iterations.

**Step 3: Apply the change.**
Use Edit to make the single change to the skill file.

**Step 4: Re-evaluate.**
Run the same evaluation as Phase 1 with the modified skill. Score all criteria across all prompts.

**Step 5: Keep or discard.**

```
IF new_score > old_score:
    KEEP. Log: "Iteration N: KEPT. Score: X/Y -> A/B. Change: <description>"
    The modified file becomes the new baseline.
ELIF new_score == old_score:
    Ask user: "Score unchanged. The change [description] didn't measurably help. Keep anyway? (Y/N)"
    If N: DISCARD and revert.
ELSE (new_score < old_score):
    DISCARD. Revert the edit. Log: "Iteration N: DISCARDED. Score: X/Y -> A/B. Change: <description>"
    Restore previous version from the last kept state.
```

**Step 6: Log the result.**
Append to `$SESSION_DIR/results.tsv`.

**Step 7: Check stopping criteria.**
- If 3 consecutive iterations produced no improvement: STOP.
- If pass rate is 100%: STOP.
- If user says stop: STOP.
- Otherwise: return to Step 1.

---

## Phase 3: Report

When the loop ends, produce a final report:

```
AUTORESEARCH SESSION REPORT
========================================
Skill:          <name>
Iterations:     <N>
Baseline:       <X>/<Y> (<Z>%)
Final:          <A>/<B> (<C>%)
Improvement:    +<delta> percentage points

Changes kept:
  1. <description> (score: X -> Y)
  2. <description> (score: Y -> Z)
  ...

Changes discarded:
  1. <description> (would have dropped score)
  ...

Session log:    <session_dir>/results.tsv
Original skill: <session_dir>/original.md
========================================
```

Save the final skill file:
```bash
cp <skill-file> "$SESSION_DIR/final.md"
```

### Diff summary
Show a diff between original and final:
```bash
diff "$SESSION_DIR/original.md" "$SESSION_DIR/final.md"
```

---

## Important Rules

1. **The evaluator is sacred.** Never modify criteria during the loop. If criteria are wrong, stop the loop, redefine them, and start a new session.
2. **One change at a time.** Bundling changes makes it impossible to know what helped. The discipline of single changes IS the method.
3. **Trust the score, not your intuition.** A change that "feels better" but scores lower gets discarded. The checklist is the ground truth.
4. **Revert completely on discard.** No partial keeps. The file returns to exactly the state before the failed change.
5. **Log everything.** The TSV log should tell the full story of what was tried and what worked.
6. **Respect the user's time.** After baseline, ask if they want to approve each change or run in "auto" mode. Most users want auto after seeing the first iteration.
