---
name: autoresearch
description: "Autonomously optimize any skill by running it repeatedly, scoring outputs against binary evals, mutating the prompt, and keeping improvements. Based on Karpathy's autoresearch methodology. Use when: optimize this skill, improve this skill, run autoresearch on, make this skill better, self-improve skill, benchmark skill, eval my skill, run evals on. Outputs: an improved SKILL.md, a results log, and a changelog of every mutation tried."
---

# Autoresearch for Skills

Most skills work about 70% of the time. The other 30% you get garbage. The fix isn't to rewrite the skill from scratch. It's to let an agent run it dozens of times, score every output, and tighten the prompt until that 30% disappears.

This skill adapts Andrej Karpathy's autoresearch methodology (autonomous experimentation loops) to Hermes Agent skills. Instead of optimizing ML training code, we optimize skill prompts.

---

## The Core Job

Take any existing skill, define what "good output" looks like as binary yes/no checks, then run an autonomous loop that:

1. Generates outputs from the skill using test inputs
2. Scores every output against the eval criteria
3. Mutates the skill prompt to fix failures
4. Keeps mutations that improve the score, discards the rest
5. Repeats until the score ceiling is hit or you stop it

**Output:** An improved SKILL.md + `results.tsv` log + `changelog.md` of every mutation attempted + a live HTML dashboard you can watch in your browser.

---

## Before Starting: Gather Context

**STOP. Do not run any experiments until all fields below are confirmed with the user.**

1. **Target skill** — Which skill do you want to optimize? (need the exact path to SKILL.md)
2. **Test inputs** — What 3-5 different prompts/scenarios should we test the skill with? (variety matters)
3. **Eval criteria** — What 3-6 binary yes/no checks define a good output?
4. **Runs per experiment** — How many times should we run the skill per mutation? Default: 5.
5. **Run interval** — How often should experiments cycle? Default: every 2 minutes.
6. **Budget cap** — Optional. Max number of experiment cycles before stopping.

---

## Step 1: Read the Skill

Before changing anything, read and understand the target skill completely.

1. Read the full SKILL.md file
2. Read any files in `references/` that the skill links to
3. Identify the skill's core job, process steps, and output format

Do NOT skip this.

---

## Step 2: Build the Eval Suite

Convert the user's eval criteria into a structured test. Every check must be binary — pass or fail.

**Format each eval as:**

```
EVAL [number]: [Short name]
Question: [Yes/no question about the output]
Pass condition: [What "yes" looks like — be specific]
Fail condition: [What triggers a "no"]
```

**Rules:**
- Binary only. Yes or no. No scales.
- Specific enough to be consistent.
- 3-6 evals is the sweet spot.

See `references/eval-guide.md` for detailed examples.

---

## Step 3: Generate the Live Dashboard

Before running any experiments, create a live HTML dashboard at `autoresearch-[skill-name]/dashboard.html`.

The dashboard must:
- Auto-refresh every 10 seconds (reads from results.tsv)
- Show a score progression line chart
- Show colored bars: green = keep, red = discard, blue = baseline
- Show a table of all experiments
- Show per-eval breakdown
- Show current status

Generate as a single self-contained HTML file with inline CSS/JS. Use Chart.js from CDN. Open it immediately.

---

## Step 4: Establish Baseline

Run the skill AS-IS before changing anything. This is experiment #0.

1. Ask the user what to name the new version.
2. Create a working directory: `autoresearch-[skill-name]/` inside the skill's folder
3. Copy the original SKILL.md into the working directory as `[user-chosen-name].md`
4. Also save `SKILL.md.baseline`
5. Create `results.tsv`, `results.json`, and `dashboard.html`, then open the dashboard
6. Run the skill [N] times using the test inputs
7. Score every output against every eval
8. Record the baseline score

**results.tsv format:**
```
experiment	score	max_score	pass_rate	status	description
0	14	20	70.0%	baseline	original skill — no changes
```

After establishing baseline, confirm the score with the user before proceeding.

---

## Step 5: Run the Experiment Loop

**LOOP:**

1. **Analyze failures.** Look at which evals are failing most. Identify the pattern.

2. **Form a hypothesis.** Pick ONE thing to change.

   Good mutations:
   - Add a specific instruction addressing the most common failure
   - Reword an ambiguous instruction
   - Add an anti-pattern ("Do NOT do X")
   - Move a buried instruction higher
   - Add or improve an example

   Bad mutations:
   - Rewriting the entire skill from scratch
   - Adding 10 new rules at once
   - Adding vague instructions

3. **Make the change.** Edit `[user-chosen-name].md` with ONE targeted mutation.

4. **Run the experiment.** Execute the skill [N] times.

5. **Score it.**

6. **Decide: keep or discard.**
   - Score improved → **KEEP.**
   - Score stayed the same → **DISCARD.**
   - Score got worse → **DISCARD.**

7. **Log the result** in results.tsv.

8. **Repeat.**

**NEVER STOP.** Run autonomously until:
- You manually stop
- Hit the budget cap
- Hit 95%+ pass rate for 3 consecutive experiments

---

## Step 6: Write the Changelog

After each experiment, append to `changelog.md`:

```markdown
## Experiment [N] — [keep/discard]

**Score:** [X]/[max] ([percent]%)
**Change:** [One sentence describing what was changed]
**Reasoning:** [Why this change was expected to help]
**Result:** [What actually happened]
**Failing outputs:** [Brief description of what still fails]
```

---

## Step 7: Deliver Results

1. **Score summary:** Baseline score → Final score
2. **Total experiments run**
3. **Keep rate**
4. **Top 3 changes that helped most**
5. **Remaining failure patterns**
6. **The improved [user-chosen-name].md**
7. **Location of results.tsv and changelog.md**

---

## Output Format

```
autoresearch-[skill-name]/
├── dashboard.html       # live browser dashboard
├── results.json         # data file powering the dashboard
├── results.tsv          # score log for every experiment
├── changelog.md         # detailed mutation log
└── SKILL.md.baseline    # original skill before optimization
```

**The original SKILL.md is NEVER modified.**

---

## The Test

A good autoresearch run:
1. Started with a baseline
2. Used binary evals only
3. Changed one thing at a time
4. Kept a complete log
5. Improved the score
6. Ran autonomously
