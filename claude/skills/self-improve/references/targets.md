# Improvement Targets Registry

Each target defines **WHY** to improve, **WHAT** to measure, **HOW** to measure it,
**WHERE** changes are allowed, and **WHAT GOOD LOOKS LIKE**.

## Target Format

```yaml
target: <kebab-case-id>
purpose: <why this matters -- the business/developer value>
metric: <what to measure>
direction: lower|higher
goal_strategy: percentage|absolute|zero
  # percentage: "reduce by 50%"
  # absolute: "get to < 20"
  # zero: "eliminate all"
default_goal: <default improvement target, e.g., "50%" or "< 10" or "0">
eval_command: <shell command that outputs a single numeric value>
test_gate: <command that must pass after any change -- exit 0 = pass>
scope:
  mutable: [files/dirs the agent MAY edit]
  readonly: [files/dirs the agent MUST NOT touch]
time_budget: <max seconds per explorer experiment>
max_experiments: <total experiments across all explorers per round>
num_explorers: <how many parallel explorer agents to spawn>
priority: <1-5, where 1 = highest>
```

## Active Targets

### 1. Test Suite Speed

```yaml
target: test-speed
purpose: >
  Fast tests mean fast CI feedback. Developers stay in flow when tests finish
  in seconds, not minutes. Slow test suites cause context-switching and reduce
  the frequency of test runs during development.
metric: total test execution time (seconds)
direction: lower
goal_strategy: percentage
default_goal: "30% reduction"
eval_command: |
  { time bash -c "$TEST_CMD" ; } 2>&1 | grep real | awk '{print $2}' | sed 's/[ms]/ /g' | awk '{printf "%.2f", $1*60+$2}'
test_gate: "$TEST_CMD"
scope:
  mutable:
    - src/**/*.ts
    - src/**/*.py
    - tests/**/*
    - jest.config.*
    - pytest.ini
    - pyproject.toml ([tool.pytest] section only)
  readonly:
    - .github/**
    - package.json (dependencies)
    - .env*
time_budget: 600
max_experiments: 20
num_explorers: 4
priority: 2
```

**Suggested explorer strategies:**
- Explorer A: Parallelize test execution and optimize test runner config
- Explorer B: Replace slow I/O with mocks and optimize fixtures
- Explorer C: Remove redundant setup/teardown and consolidate test helpers
- Explorer D: Profile slowest tests and target the top 20%

### 2. Build Time

```yaml
target: build-time
purpose: >
  Fast builds keep developer iteration tight and CI pipelines short.
  Every second saved on build time compounds across every commit, every PR,
  every developer.
metric: build wall-clock time (seconds)
direction: lower
goal_strategy: percentage
default_goal: "25% reduction"
eval_command: |
  { time bash -c "$BUILD_CMD" ; } 2>&1 | grep real | awk '{print $2}' | sed 's/[ms]/ /g' | awk '{printf "%.2f", $1*60+$2}'
test_gate: "$BUILD_CMD && $TEST_CMD"
scope:
  mutable:
    - webpack.config.*
    - tsconfig*.json
    - vite.config.*
    - rollup.config.*
    - esbuild.*
    - src/**/*.ts (import restructuring only)
  readonly:
    - package.json
    - .github/**
time_budget: 300
max_experiments: 12
num_explorers: 3
priority: 3
```

**Suggested explorer strategies:**
- Explorer A: Optimize bundler/compiler config (caching, parallelism, transpile-only)
- Explorer B: Reduce import graph depth and eliminate barrel re-exports
- Explorer C: Exclude unnecessary files and enable incremental builds

### 3. Lint / Static Analysis Warnings

```yaml
target: lint-warnings
purpose: >
  Lint warnings are signal buried in noise. Reducing them makes real issues
  visible, improves code quality, and builds team discipline around clean code.
  Zero warnings should be the goal -- then you can enable warnings-as-errors.
metric: total warning + error count
direction: lower
goal_strategy: percentage
default_goal: "60% reduction"
eval_command: |
  $LINT_CMD 2>&1 | tail -1
scope:
  mutable:
    - src/**/*.ts
    - src/**/*.py
    - src/**/*.js
  readonly:
    - .eslintrc*
    - .pylintrc
    - .flake8
    - pyproject.toml (lint config sections)
test_gate: "$TEST_CMD"
time_budget: 300
max_experiments: 20
num_explorers: 4
priority: 2
```

**Suggested explorer strategies:**
- Explorer A: Remove unused imports, variables, and dead code
- Explorer B: Add missing type annotations and fix type errors
- Explorer C: Fix naming convention violations and style issues
- Explorer D: Resolve deprecation warnings and modernize API usage

### 4. Bundle / Artifact Size

```yaml
target: bundle-size
purpose: >
  Smaller bundles mean faster load times for users. Every KB matters on
  mobile networks. Keeping bundles lean also indicates good code hygiene --
  no dead code, no unnecessary dependencies pulled in.
metric: total output size (KB)
direction: lower
goal_strategy: percentage
default_goal: "20% reduction"
eval_command: |
  $BUILD_CMD > /dev/null 2>&1 && du -sk dist/ | awk '{print $1}'
test_gate: "$BUILD_CMD && $TEST_CMD"
scope:
  mutable:
    - src/**/*
    - webpack.config.*
    - tsconfig*.json
  readonly:
    - package.json
    - public/**
    - .github/**
time_budget: 300
max_experiments: 12
num_explorers: 3
priority: 4
```

**Suggested explorer strategies:**
- Explorer A: Remove dead exports and optimize import patterns for tree shaking
- Explorer B: Lazy-load heavy components and split large chunks
- Explorer C: Replace heavy utility usage with native equivalents

### 5. Test Coverage

```yaml
target: test-coverage
purpose: >
  Higher coverage means fewer bugs ship to production. Coverage is not a vanity
  metric when targeted at critical paths -- the goal is confidence that key
  behavior is verified, not 100% for its own sake.
metric: line coverage percentage
direction: higher
goal_strategy: absolute
default_goal: "> 80%"
eval_command: |
  $COVERAGE_CMD 2>&1 | grep -E 'Lines|TOTAL' | awk '{print $NF}' | tr -d '%'
test_gate: "$TEST_CMD"
scope:
  mutable:
    - tests/**/*
    - src/**/*.test.*
    - src/**/*.spec.*
  readonly:
    - src/**/*.ts (production code -- only test files may be added/modified)
    - package.json
time_budget: 600
max_experiments: 20
num_explorers: 4
priority: 3
```

**Suggested explorer strategies:**
- Explorer A: Add unit tests for untested public functions
- Explorer B: Cover error handling paths and edge cases
- Explorer C: Add tests for conditional branches with lowest coverage
- Explorer D: Add integration tests for untested API endpoints

### 6. Shell Script Quality

```yaml
target: shellcheck-issues
purpose: >
  Shell scripts are critical infrastructure -- hooks, installers, CI glue.
  Shellcheck issues indicate real bugs (unquoted variables, word splitting)
  not just style nits. Fixing them prevents silent failures in automation.
metric: total shellcheck finding count
direction: lower
goal_strategy: zero
default_goal: "0 issues"
eval_command: |
  shellcheck .claude/hooks/*.sh claude/**/*.sh 2>&1 | grep -c '^In ' || echo 0
test_gate: "bash claude/tests/test-hooks.sh"
scope:
  mutable:
    - .claude/hooks/*.sh
    - claude/**/*.sh
  readonly:
    - .claude/settings.json
time_budget: 120
max_experiments: 10
num_explorers: 2
priority: 1
```

**Suggested explorer strategies:**
- Explorer A: Fix quoting, word-splitting, and globbing issues (SC2086, SC2046)
- Explorer B: Modernize syntax (replace backticks, use `[[`, add `set -euo pipefail`)

## Custom / Ad-Hoc Targets

When the user provides a free-form purpose instead of a target ID, the skill
should construct an ad-hoc target following this format:

```yaml
target: custom-<kebab-case-summary>
purpose: <the user's stated purpose>
metric: <inferred from purpose>
direction: <inferred>
goal_strategy: <inferred>
default_goal: <set based on baseline measurement>
eval_command: <constructed based on project environment>
test_gate: "$TEST_CMD"
scope:
  mutable: <inferred from purpose -- be conservative>
  readonly: <everything else>
time_budget: 300
max_experiments: 15
num_explorers: 3
priority: 1
```

The skill MUST confirm the ad-hoc target definition with the user before proceeding
if the purpose is ambiguous.

## Adding New Targets

1. Start with the **purpose** -- why does this improvement matter?
2. Define a measurable metric with an eval_command that outputs a single number
3. Set a goal_strategy and default_goal that is ambitious but achievable in one night
4. Define scope.mutable conservatively -- only the files that need to change
5. Set scope.readonly to protect everything else
6. Choose num_explorers (2-5 depending on strategy diversity)
7. Assign priority relative to existing targets

## Environment Variables

Set by the skill before spawning agents:

| Variable | Description | Example |
|----------|-------------|---------|
| `$TEST_CMD` | Project test command | `npm test`, `pytest` |
| `$BUILD_CMD` | Project build command | `npm run build`, `make` |
| `$LINT_CMD` | Project lint command | `npm run lint`, `flake8 src/` |
| `$COVERAGE_CMD` | Coverage command | `npm test -- --coverage`, `pytest --cov` |
