---
name: self-improve
description: >
  Run autonomous improvement loops on a codebase overnight, inspired by Karpathy's
  autoresearch. Iteratively modifies code, measures a metric, keeps improvements,
  discards regressions. Use when user says "run self-improve", "autonomous improvement",
  "nightly improvement", "optimize overnight", "run the Karpathy loop", "auto-improve",
  "self-improve this repo", or wants unattended iterative optimization of test speed,
  build time, lint warnings, bundle size, test coverage, or shell script quality.
  Do NOT use for one-off bug fixes (use build-fix), code review (use code-review),
  manual refactoring, or any task where the user wants to be in the loop for each change.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
model: sonnet
user-invocable: true
arguments: target (optional -- target ID from targets.md, or "all" to rotate through targets by priority)
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: workflow
  tags: [autonomous, optimization, self-improvement, karpathy-loop, nightly]
---

# Self-Improve Skill

Autonomous iterative improvement of a codebase. Inspired by [Karpathy's autoresearch](https://github.com/karpathy/autoresearch) -- the greedy hill-climbing loop over code modifications with a single metric as the objective function.

**Core idea:** Modify code → evaluate metric → keep if better → repeat.

## Arguments

- `$ARGUMENTS` -- Target ID (e.g., `test-speed`, `lint-warnings`) or `all` for priority rotation.
- If no argument, prompt the user to select a target or default to `all`.

## Instructions

### Step 1: Detect Project Environment

Scan the repository to determine:

1. **Language/framework** -- Check for `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Makefile`
2. **Test command** -- `npm test`, `pytest`, `cargo test`, `go test ./...`, `make test`
3. **Build command** -- `npm run build`, `python -m build`, `cargo build`, `go build`, `make`
4. **Lint command** -- `npm run lint`, `flake8`, `clippy`, `golangci-lint`
5. **Coverage command** -- `npm test -- --coverage`, `pytest --cov`, `cargo tarpaulin`

Set environment variables: `$TEST_CMD`, `$BUILD_CMD`, `$LINT_CMD`, `$COVERAGE_CMD`.

If any command cannot be detected, skip targets that depend on it and note which targets are unavailable.

### Step 2: Select Target(s)

If `$ARGUMENTS` is a specific target ID:
- Load that target definition from `references/targets.md`
- Verify the required commands exist

If `$ARGUMENTS` is `all` or empty:
- Load all targets from `references/targets.md`
- Sort by priority (1 = highest)
- Skip targets whose required commands are unavailable
- Allocate experiments proportionally to priority

### Step 3: Create Improvement Branch

```bash
BRANCH="auto/self-improve/$(date +%Y-%m-%d)"
git checkout -b "$BRANCH"
```

Initialize results.tsv if it does not exist:

```bash
echo -e "commit\ttarget\tmetric\tbaseline\tdelta\tstatus\tdescription\ttimestamp" > results.tsv
```

Add `results.tsv` to `.gitignore` if not already there (it should NOT be committed).

### Step 4: Capture Baseline

For each selected target, run the eval_command and record the baseline:

```bash
BASELINE=$($EVAL_CMD)
echo "Baseline for $TARGET: $BASELINE"
```

If baseline capture fails, skip that target and note the error.

### Step 5: Run the Karpathy Loop

For each target (in priority order), launch the self-improver agent:

Pass to the agent:
- The target definition (from targets.md)
- The baseline metric value
- Path to results.tsv
- Max experiments for this target
- The current branch name
- The scoring rules (from scoring.md)
- The strategy catalog (from strategies.md)

The agent runs autonomously until:
- `max_experiments` reached for this target
- 5 consecutive crashes
- All strategies exhausted

Then move to the next target.

### Step 6: Generate Summary Report

After all targets are processed, produce a summary:

```markdown
# Self-Improve Report -- [date]

## Results by Target

### [target-id]
- Baseline: [value]
- Final: [value]
- Improvement: [delta] ([percentage]%)
- Experiments: [kept]/[total] kept
- Best change: [description of highest-impact keep]

## Experiment Log
[Top 10 experiments by impact, from results.tsv]

## Branch
All improvements on branch: `auto/self-improve/YYYY-MM-DD`
Ready for human review and merge.
```

### Step 7: Notify

Output the summary report. If the project has a notification mechanism (e.g., GitHub PR), create a draft PR with the summary as the body:

- Title: `auto: self-improve [date] -- [N] improvements`
- Body: The summary report from Step 6
- Base: main branch
- Head: the improvement branch
- Mark as draft (human must review before merge)

## Examples

Example 1: Nightly lint cleanup
User says: `/self-improve lint-warnings`
Actions:
1. Detect project uses TypeScript + ESLint
2. Set `$LINT_CMD` to `npm run lint`
3. Create branch `auto/self-improve/2026-03-24`
4. Baseline: 47 warnings
5. Agent runs 20 experiments:
   - Exp 1: Remove 12 unused imports → 35 warnings → KEEP
   - Exp 2: Add return types to 8 functions → 27 warnings → KEEP
   - Exp 3: Fix naming conventions → 24 warnings → KEEP
   - ...
6. Final: 11 warnings (76% reduction)
7. Draft PR created for morning review

Example 2: Overnight full sweep
User says: `/self-improve all`
Actions:
1. Detect project environment
2. Select targets by priority: shellcheck-issues (1), lint-warnings (2), test-speed (2), test-coverage (3), build-time (3), bundle-size (4)
3. Create branch, capture baselines
4. Run loop for each target, allocating experiments proportionally
5. Summary: 4 shellcheck fixes, 15 lint fixes, 2 test speedups, 3 new test files
6. Draft PR with full report

Example 3: Single target with limited scope
User says: `/self-improve test-speed`
Actions:
1. Detect `npm test` as test command
2. Baseline: 34.2s
3. Agent experiments with parallelization, fixture optimization, mock improvements
4. Final: 28.1s (18% faster)
5. 6 kept commits, all tests still passing

## Troubleshooting

Error: No test command detected
Cause: Project has no standard test runner configuration
Solution: Set `$TEST_CMD` manually before running, or add a `test` script to package.json

Error: Baseline capture fails
Cause: The eval command errors out before producing a metric
Solution: Run the eval command manually to debug. Common issues: missing dependencies, wrong working directory

Error: All experiments crash
Cause: The test gate or eval command is unstable
Solution: Check that tests pass reliably on the current branch before starting self-improve. Flaky tests will cause spurious crashes.

Error: No improvement after max experiments
Cause: The codebase may already be well-optimized for this target, or strategies need updating
Solution: Check results.tsv for patterns. Add new strategies to strategies.md. Try a different target.

Error: Agent modifies files outside scope
Cause: Bug in agent instructions or ambiguous scope definition
Solution: Review the target's scope.mutable definition. The agent MUST be constrained to only those paths.

## Rules

- **Human reviews everything** -- Changes land on a branch, never main. A human must review and merge.
- **Tests are sacred** -- No change that breaks existing tests is ever kept.
- **One change per commit** -- Every experiment is a single, atomic, reviewable commit.
- **No new dependencies** -- The agent works within existing packages only.
- **Log everything** -- Every experiment (keep, discard, crash) is recorded in results.tsv.
- **Simplicity wins** -- Removing code that maintains metric parity is an improvement.
- **Scope is enforced** -- The agent MUST NOT touch files outside the target's mutable scope.
- **Budget is hard** -- max_experiments and time_budget are not suggestions, they are limits.
- **Git is the undo mechanism** -- Always commit before eval, always reset on failure.
- **Context window hygiene** -- Redirect command output to files, grep for metrics only.
