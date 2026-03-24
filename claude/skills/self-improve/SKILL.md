---
name: self-improve
description: >
  Run autonomous improvement cycles on a codebase overnight. Defines a purpose and
  improvement goals, spawns explorer agents to find candidates in parallel, then
  evaluates all candidates in a tournament to pick the best. Use when user says
  "run self-improve", "autonomous improvement", "nightly improvement", "optimize
  overnight", "auto-improve", "self-improve this repo", or wants unattended
  iterative optimization of any measurable aspect of the codebase.
  Do NOT use for one-off bug fixes (use build-fix), code review (use code-review),
  manual refactoring, or any task where the user wants to be in the loop for each change.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
model: sonnet
user-invocable: true
arguments: target (optional -- target ID from targets.md, a free-form purpose statement, or "all")
license: MIT
metadata:
  author: SGridworks
  version: 2.0.0
  category: workflow
  tags: [autonomous, optimization, self-improvement, nightly, tournament]
---

# Self-Improve Skill

Autonomous iterative improvement of a codebase. Inspired by Karpathy's autoresearch
but redesigned around **purpose-driven exploration with tournament selection**.

**Core idea:** Define purpose → set goals → explore in parallel → evaluate all candidates → pick the best.

## Arguments

- `$ARGUMENTS` -- A target ID (e.g., `test-speed`), a free-form purpose (e.g., "make the API response times faster"), or `all`.
- If no argument, prompt the user to define a purpose or select a target.

## Instructions

### Phase 1: Define Purpose

Every run starts by answering **why** before **what**.

1. If `$ARGUMENTS` is a known target ID from `references/targets.md`:
   - Load the target definition
   - Generate a purpose statement from it (e.g., "Reduce test suite execution time so CI feedback is faster for developers")

2. If `$ARGUMENTS` is a free-form purpose statement:
   - Parse the intent
   - Map it to one or more targets from `references/targets.md`, OR
   - Define a new ad-hoc target with metric, eval_command, and scope

3. If `$ARGUMENTS` is `all` or empty:
   - Scan the repository (see environment detection below)
   - Identify the highest-value improvement areas
   - Generate a purpose statement for each

**Output a Purpose Brief:**

```markdown
## Purpose Brief

**Why:** [one sentence -- the business/developer value of this improvement]
**What:** [the aspect being improved]
**Metric:** [how we measure it]
**Current baseline:** [measured value]
**Goal:** [specific target value or percentage improvement]
**Scope:** [which files/areas are in play]
**Constraints:** [what must NOT break]
```

### Phase 2: Detect Environment and Capture Baseline

1. **Detect project environment:**
   - Language/framework: Check for `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Makefile`
   - Test command, build command, lint command, coverage command
   - Set `$TEST_CMD`, `$BUILD_CMD`, `$LINT_CMD`, `$COVERAGE_CMD`

2. **Capture baseline metric:**
   - Run the eval_command for the target
   - Record the numeric baseline value
   - Run it 3 times if the metric is timing-based (use the median to account for variance)

3. **Set improvement goal:**
   - Based on the purpose, set a specific, measurable goal
   - Example: "Reduce from 47 lint warnings to < 20" or "Improve test coverage from 62% to > 75%"
   - Goals should be ambitious but achievable in one nightly run

If baseline capture fails, stop and report the error -- do not proceed blind.

### Phase 3: Create Branch and Initialize

```bash
BRANCH="auto/self-improve/$(date +%Y-%m-%d)-${TARGET}"
git checkout -b "$BRANCH"
```

Initialize the run log:

```bash
mkdir -p .self-improve
cat > .self-improve/run.json <<INIT
{
  "date": "$(date -Iseconds)",
  "purpose": "$PURPOSE",
  "target": "$TARGET",
  "baseline": $BASELINE,
  "goal": "$GOAL",
  "candidates": [],
  "winner": null
}
INIT
```

Add `.self-improve/` to `.gitignore` if not already present.

### Phase 4: Explore -- Spawn Candidate Agents

This is the key difference from greedy hill-climbing. Instead of one agent making
sequential keep/discard decisions, we spawn **multiple explorer agents in parallel**,
each pursuing a different strategy.

1. **Select strategies** from `references/strategies.md` for the current target.
   Pick 3-5 diverse strategies spanning different risk tiers (A, B, C).

2. **Spawn explorer agents** -- each in its own worktree:

   Each explorer agent receives:
   - The Purpose Brief from Phase 1
   - The baseline metric and goal
   - ONE assigned strategy (or a small cluster of related strategies)
   - The scoring criteria from `references/scoring.md`
   - The mutable scope from the target definition
   - A candidate ID (e.g., `candidate-1`, `candidate-2`)

   Each explorer agent:
   - Reads the relevant code
   - Implements improvements following its assigned strategy
   - Makes one or more commits (each atomic and clean)
   - Runs the test gate to verify nothing is broken
   - Runs the eval_command to measure its own result
   - Reports back: metric value, description of changes, number of commits, diff stats

3. **Explorers work independently.** They do NOT see each other's changes.
   This prevents groupthink and ensures diverse approaches.

4. **Budget per explorer:** Each explorer gets a subset of the total experiment budget
   (e.g., if max_experiments = 20 and we have 4 explorers, each gets ~5 experiments
   to iterate within their strategy before reporting their best result).

### Phase 5: Evaluate -- Tournament Selection

Once all explorers report back, run a tournament:

1. **Collect candidates:**
   Gather each explorer's best result:
   ```
   candidate | strategy | metric_value | delta | commits | lines_changed | tests_pass
   ```

2. **Disqualify** any candidate where:
   - Tests do not pass
   - Metric is worse than baseline
   - Changes are outside the allowed scope

3. **Rank qualifying candidates** using the scoring formula from `references/scoring.md`:
   - Primary: metric improvement (delta from baseline toward goal)
   - Secondary: simplicity (fewer lines changed, fewer commits = tiebreaker)
   - Tertiary: goal proximity (how close to the stated goal)

4. **Independent verification** -- spawn the evaluator agent to:
   - Check out each qualifying candidate's branch
   - Re-run the eval_command independently (explorers cannot be trusted to grade themselves)
   - Run the full test suite (not just the test gate)
   - Verify the diff is within scope
   - Run eval 3 times for timing-based metrics (use median)

5. **Pick the winner:**
   - The candidate with the best verified metric that passes all checks
   - If multiple candidates are within the noise floor of each other, pick the simpler one
   - If NO candidate improves the metric, report "no improvement found" -- do not force a bad change

### Phase 6: Merge Winner and Iterate

If a winner is found:

1. **Cherry-pick or merge** the winner's commits onto the improvement branch
2. **Update baseline** to the winner's metric value
3. **Log the round** in `.self-improve/run.json`

Then decide whether to iterate:

- If the goal has been met → stop, move to reporting
- If the goal has NOT been met AND the budget allows → run another round (Phase 4-5)
  with the new baseline, excluding strategies already tried
- If the budget is exhausted → stop, report partial progress
- Max 3 rounds per target per night (to prevent runaway loops)

### Phase 7: Generate Report

```markdown
# Self-Improve Report -- [date]

## Purpose
[The purpose brief from Phase 1]

## Results

| Metric | Baseline | Goal | Final | Progress |
|--------|----------|------|-------|----------|
| [name] | [value]  | [value] | [value] | [%] toward goal |

## Winning Strategy
[Which strategy won the tournament and why]

## Candidates Evaluated
| Candidate | Strategy | Metric | Delta | Verdict |
|-----------|----------|--------|-------|---------|
| candidate-1 | [name] | [value] | [delta] | winner / disqualified / runner-up |
| candidate-2 | [name] | [value] | [delta] | ... |

## Rounds
[How many rounds were run, and what each round contributed]

## Changes Made
[Summary of commits on the improvement branch]

## Branch
`auto/self-improve/YYYY-MM-DD-target`
Ready for human review and merge.
```

### Phase 8: Deliver

1. Output the report
2. Create a draft PR if GitHub is available:
   - Title: `auto: [purpose summary] -- [metric delta]`
   - Body: The report from Phase 7
   - Base: main branch
   - Mark as draft
3. If no PR mechanism, leave the branch ready for manual review

## Examples

Example 1: Purpose-driven lint cleanup
User says: `/self-improve lint-warnings`
Flow:
1. Purpose: "Reduce lint warnings so the codebase is cleaner and CI noise is lower"
2. Baseline: 47 warnings, Goal: < 15 warnings
3. Spawn 4 explorers:
   - Explorer A: Remove unused imports and variables
   - Explorer B: Add missing type annotations
   - Explorer C: Fix naming convention violations
   - Explorer D: Resolve deprecation warnings
4. Tournament results:
   - A: 35 warnings (12 fixed) -- QUALIFIED
   - B: 29 warnings (18 fixed) -- QUALIFIED
   - C: 41 warnings (6 fixed) -- QUALIFIED
   - D: 44 warnings (3 fixed) -- QUALIFIED
5. Winner: Explorer B (best delta), verified independently
6. Round 2 with new baseline 29, spawn new explorers
7. Final: 11 warnings (76% reduction), goal met
8. Draft PR created

Example 2: Free-form purpose
User says: `/self-improve "make our API tests less flaky"`
Flow:
1. Purpose: "Reduce test flakiness so CI results are trustworthy"
2. Metric defined ad-hoc: run test suite 5 times, count failures
3. Baseline: 3/5 runs have at least one failure
4. Explorers target: timing-dependent assertions, shared mutable state, missing test isolation, race conditions
5. Tournament picks the candidate with 0/5 flaky runs
6. Report and PR

Example 3: Overnight full sweep
User says: `/self-improve all`
Flow:
1. Detect environment, identify top 3 targets by priority
2. Run Phase 1-6 for each target sequentially
3. Consolidated report covering all targets
4. One PR per target, or one combined PR

## Troubleshooting

Error: No test command detected
Cause: Project has no standard test runner configuration
Solution: Set `$TEST_CMD` manually before running, or add a `test` script to package.json

Error: Baseline capture fails
Cause: The eval command errors out before producing a metric
Solution: Run the eval command manually to debug -- missing dependencies, wrong working directory

Error: All explorers crash
Cause: The test gate or eval command is unstable
Solution: Verify tests pass reliably before starting. Flaky tests poison the tournament.

Error: No candidate beats baseline
Cause: Codebase may be well-optimized, or strategies need updating
Solution: This is a valid outcome -- report "no improvement found" honestly. Add new strategies to strategies.md.

Error: Explorers produce conflicting changes
Cause: Two explorers modified the same file differently
Solution: Each explorer works in an isolated worktree. Only the winner's changes are merged.

## Rules

- **Purpose first** -- Every run must have a clear purpose statement before any code is touched.
- **Goals are explicit** -- Set a measurable target before exploring. "Make it better" is not a goal.
- **Human reviews everything** -- Changes land on a branch, never main. A human must review and merge.
- **Tests are sacred** -- No candidate that breaks existing tests can win the tournament.
- **Independent verification** -- Explorer self-reported metrics are verified by a separate evaluator.
- **Simplicity wins ties** -- When two candidates are within noise floor, the simpler one wins.
- **No new dependencies** -- Explorers work within existing packages only.
- **Scope is enforced** -- Explorers MUST NOT touch files outside the target's mutable scope.
- **Budget is hard** -- max_experiments, max rounds (3), and time_budget are enforced.
- **Honest reporting** -- If nothing improved, say so. Never force a bad change to show progress.
- **Context window hygiene** -- Redirect command output to log files, grep for metrics only.
