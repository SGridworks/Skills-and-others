# Eval Guide

How to write eval criteria that actually improve your skills instead of giving you false confidence.

---

## The Golden Rule

Every eval must be a yes/no question. Not a scale. Not a vibe check. Binary.

Why: Scales compound variability. Binary evals give you a reliable signal.

---

## Good Evals vs Bad Evals

### Text/copy skills

**Bad:** "Is the writing good?", "Rate the engagement potential 1-10", "Does it sound like a human?"

**Good:**
- "Does the output contain zero phrases from this banned list: [game-changer, here's the kicker, the best part]?"
- "Does the opening sentence reference a specific time, place, or sensory detail?"
- "Is the output between 150-400 words?"
- "Does it end with a specific CTA?"

### Visual/design skills

**Bad:** "Does it look professional?", "Rate the visual quality 1-5"

**Good:**
- "Is all text in the image legible with no truncated or overlapping words?"
- "Does the color palette use only soft/pastel tones with no neon or high-saturation colors?"
- "Is the layout linear — left-to-right or top-to-bottom?"
- "Is the image free of numbered steps or ordinals?"

### Code/technical skills

**Bad:** "Is the code clean?", "Does it follow best practices?"

**Good:**
- "Does the code run without errors?"
- "Does the output contain zero TODO or placeholder comments?"
- "Are all function and variable names descriptive?"
- "Does the code include error handling for all external calls?"

### Document skills

**Bad:** "Is it comprehensive?", "Does it address the client's needs?"

**Good:**
- "Does the document contain all required sections: [list them]?"
- "Is every claim backed by a specific number, date, or source?"
- "Is the document under [X] pages/words?"

---

## Common Mistakes

### 1. Too many evals
More than 6 evals and the skill starts gaming them. Pick the 3-6 checks that matter most.

### 2. Too narrow/rigid
" Must contain exactly 3 bullet points" creates skills that technically pass but produce weird output.

### 3. Overlapping evals
If eval 1 is "Is the text grammatically correct?" and eval 4 is "Are there any spelling errors?" — you're double-counting.

### 4. Unmeasurable by an agent
"Would a human find this engaging?" — translate to observable signals instead.

---

## Writing Your Evals: The 3-Question Test

1. Could two different agents score the same output and agree? If not, the eval is too subjective.
2. Could a skill game this eval without actually improving? If yes, the eval is too narrow.
3. Does this eval test something the user actually cares about? If not, drop it.

---

## Template

```
EVAL [N]: [Short name]
Question: [Yes/no question]
Pass: [What "yes" looks like — one sentence, specific]
Fail: [What triggers "no" — one sentence, specific]
```

Example:
```
EVAL 1: Text legibility
Question: Is all text in the output fully legible with no truncated words?
Pass: Every word is complete and readable
Fail: Any word is partially hidden or cut off
```
