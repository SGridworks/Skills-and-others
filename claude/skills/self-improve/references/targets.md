# Improvement Targets Registry

Each target defines WHAT to improve, HOW to measure it, and WHERE changes are allowed.

## Target Format

```yaml
target: <kebab-case-id>
metric: <what to measure>
direction: lower|higher        # lower = better (time, size, errors) or higher = better (coverage)
eval_command: <shell command that outputs the metric value>
baseline_command: <optional -- run before modifications to capture baseline>
scope:
  mutable: [files/dirs the agent MAY edit]
  readonly: [files/dirs the agent MUST NOT touch]
test_gate: <command that must pass after any change -- exit 0 = pass>
time_budget: <max seconds per experiment>
max_experiments: <cap per nightly run for this target>
priority: <1-5, where 1 = highest>
```

## Active Targets

### 1. Test Suite Speed

```yaml
target: test-speed
metric: total test execution time (seconds)
direction: lower
eval_command: |
  { time bash -c "$TEST_CMD" ; } 2>&1 | grep real | awk '{print $2}' | sed 's/[ms]/ /g' | awk '{printf "%.2f", $1*60+$2}'
baseline_command: same as eval_command
scope:
  mutable:
    - src/**/*.ts
    - src/**/*.py
    - tests/**/*
    - jest.config.*
    - pytest.ini
    - pyproject.toml (only [tool.pytest] section)
  readonly:
    - .github/**
    - package.json (dependencies -- devDependencies may be reordered but not changed)
    - .env*
test_gate: "$TEST_CMD"
time_budget: 600
max_experiments: 15
priority: 2
```

**Typical strategies:** Parallelize test execution, remove redundant setup/teardown, replace slow I/O with mocks, optimize fixtures, reorder test discovery.

### 2. Build Time

```yaml
target: build-time
metric: build wall-clock time (seconds)
direction: lower
eval_command: |
  { time bash -c "$BUILD_CMD" ; } 2>&1 | grep real | awk '{print $2}' | sed 's/[ms]/ /g' | awk '{printf "%.2f", $1*60+$2}'
scope:
  mutable:
    - webpack.config.*
    - tsconfig*.json
    - vite.config.*
    - rollup.config.*
    - esbuild.*
    - src/**/*.ts (only import restructuring)
  readonly:
    - package.json
    - .github/**
test_gate: "$BUILD_CMD && $TEST_CMD"
time_budget: 300
max_experiments: 10
priority: 3
```

**Typical strategies:** Optimize bundler config, reduce unnecessary transpilation, enable caching, tree-shake unused imports, split chunks.

### 3. Lint / Static Analysis Warnings

```yaml
target: lint-warnings
metric: total warning + error count
direction: lower
eval_command: |
  $LINT_CMD 2>&1 | tail -1  # most linters print summary on last line
scope:
  mutable:
    - src/**/*.ts
    - src/**/*.py
    - src/**/*.js
  readonly:
    - .eslintrc*
    - .pylintrc
    - .flake8
    - pyproject.toml (only code files, not config)
test_gate: "$TEST_CMD"
time_budget: 300
max_experiments: 20
priority: 2
```

**Typical strategies:** Fix type errors, add missing return types, remove unused imports/variables, fix naming conventions, resolve deprecation warnings.

### 4. Bundle / Artifact Size

```yaml
target: bundle-size
metric: total output size (KB)
direction: lower
eval_command: |
  $BUILD_CMD > /dev/null 2>&1 && du -sk dist/ | awk '{print $1}'
scope:
  mutable:
    - src/**/*
    - webpack.config.*
    - tsconfig*.json
  readonly:
    - package.json
    - public/**
    - .github/**
test_gate: "$BUILD_CMD && $TEST_CMD"
time_budget: 300
max_experiments: 10
priority: 4
```

**Typical strategies:** Remove dead code, optimize imports, replace heavy dependencies with lighter alternatives (without adding new deps), enable tree shaking, lazy load modules.

### 5. Test Coverage

```yaml
target: test-coverage
metric: line coverage percentage
direction: higher
eval_command: |
  $COVERAGE_CMD 2>&1 | grep -E 'Lines|TOTAL' | awk '{print $NF}' | tr -d '%'
scope:
  mutable:
    - tests/**/*
    - src/**/*.test.*
    - src/**/*.spec.*
  readonly:
    - src/**/*.ts (production code -- only tests may be added/modified)
    - package.json
test_gate: "$TEST_CMD"
time_budget: 600
max_experiments: 15
priority: 3
```

**Typical strategies:** Add missing unit tests, cover untested branches, add edge case tests, cover error paths.

### 6. Shell Script Quality

```yaml
target: shellcheck-issues
metric: total shellcheck finding count
direction: lower
eval_command: |
  shellcheck .claude/hooks/*.sh claude/**/*.sh 2>&1 | grep -c '^In ' || echo 0
scope:
  mutable:
    - .claude/hooks/*.sh
    - claude/**/*.sh
  readonly:
    - .claude/settings.json
test_gate: "bash claude/tests/test-hooks.sh"
time_budget: 120
max_experiments: 10
priority: 1
```

**Typical strategies:** Fix quoting issues, use arrays instead of word splitting, add error handling, replace deprecated syntax, fix SC2086/SC2046 patterns.

## Adding New Targets

To add a target:

1. Define the target block in yaml format above
2. Ensure `eval_command` outputs a single numeric value
3. Ensure `test_gate` returns exit code 0 on success
4. Set `scope.readonly` to protect critical files
5. Set a reasonable `time_budget` and `max_experiments`
6. Assign priority relative to existing targets

## Environment Variables

Targets use these env vars (set by the skill before invoking the agent):

| Variable | Description | Example |
|----------|-------------|---------|
| `$TEST_CMD` | Project test command | `npm test`, `pytest` |
| `$BUILD_CMD` | Project build command | `npm run build`, `make` |
| `$LINT_CMD` | Project lint command | `npm run lint`, `flake8 src/` |
| `$COVERAGE_CMD` | Coverage command | `npm test -- --coverage`, `pytest --cov` |
