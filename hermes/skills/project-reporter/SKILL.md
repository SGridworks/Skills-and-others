# Project Reporter - Weekly Status Generator

**Type:** Generator  
**Trigger:** weekly report, status update, project update

## Purpose
Generate weekly project status reports in the SGridWorks voice - direct, evidence-based, no fluff.

## Generator Steps

### Step 1: Load Voice Reference
Load `references/sgridworks-tone.md` to internalize the writing style.

Key principles:
- Direct, first-principles thinking
- Short sentences
- Evidence with every claim
- Lead with action
- Fail forward attitude
- No corporate platitudes

### Step 2: Load Template
Load `assets/weekly-status-template.md` for report structure.

### Step 3: Gather Information

**Auto-detect first, then ask for gaps.**

#### 3a. Detect project from context
Match cwd or user input to known projects:
- BTM-Optimize: `~/btm-optimize/`
- DNM: `~/Projects/Dynamic-Network-Model/`
- Hermes: `~/hermes-agent/`
- SGridworks site: `~/Projects/sgridworks-website/`

#### 3b. Pull accomplishments from git (7 days)
```bash
cd <project-dir>
git log --oneline --since="7 days ago" --format="%h %s (%ar)" | head -15
```
Parse commit messages into accomplishment bullets. Conventional commit prefixes map to:
- `feat:` -> "Shipped: ..."
- `fix:` -> "Fixed: ..."
- `refactor:` -> "Improved: ..."
- `test:` -> "Tested: ..." (usually fold into the feat it supports)

#### 3c. Pull test counts if available
```bash
cd <project-dir>
# Python projects
find . -name "test_*.py" -o -name "*_test.py" | xargs grep -c "def test_" 2>/dev/null | awk -F: '{s+=$2} END {print s" tests"}'
```

#### 3d. Ask user only for what git can't tell you
- Status Color (Green/Yellow/Red) -- ask
- Blockers + mitigation -- ask
- Next week priorities -- ask
- Pipeline/leads -- ask only if relevant

### Step 4: Fill Template
Map gathered info to template sections:
- Fill header with project, date, status
- Executive Summary: 2-3 bullets synthesizing accomplishments + impact
- Accomplishments: Bulleted list with metrics
- Blockers/Risks: Current obstacles + mitigation status
- Next Week: Prioritized task list
- Pipeline: Add if provided, omit if empty

### Step 5: Apply Voice (from sgridworks-tone.md)

Concrete rules -- apply each one:

1. **Max 15 words per sentence.** Split anything longer.
2. **Every claim needs a number.** "Shipped auth" -> "Shipped auth. 340 signups in 24h."
3. **Start with verbs.** "There was a discussion" -> "Discussed roadmap. Cut 3 features."
4. **Kill these words:** very, really, quite, leverage, synergy, optimize, strategic, we believe, it seems
5. **Blockers are data, not apologies.** "Delay: vendor API broke. Fix: wrapper, ETA Friday."
6. **Quick check before output:** Can I halve this sentence? Where's the evidence? Does it start with a verb?

### Step 6: Output
Deliver formatted report ready to share.

## Output Format
```
# [Project Name] — Week of [Date]

[Formatted report content]
```
