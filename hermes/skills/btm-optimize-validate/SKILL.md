# BTM-Optimize Validation Reviewer

**Trigger:** btm-optimize validation, regression test, check run

## Purpose
Review BTM-Optimize runs/code against regression checklist to catch common gotchas and validate implementation quality.

## Review Process

### Step 1: Accept Input

The user may provide one or more of:
- **Config dict/file** -- check for parameter issues
- **Code snippet** -- check for implementation bugs
- **Run output/logs** -- check for solver or result issues
- **Nothing specific** -- run the full checklist interactively

If input is partial, run only applicable checks. Don't ask for everything upfront.

### Step 2: Apply Regression Checks

Run these checks in order. For each, grep/search the provided artifacts:

**[ERROR] Battery SOC Initialization**
- Look for: `initial_soc` missing from config, or Battery() called without it
- Detection: `grep -n "initial_soc\|Battery(" <file>`
- If missing: defaults to 50% which is often wrong for cycling scenarios
- Fix: `initial_soc=0.2` for peak-shaving, `initial_soc=0.5` for arbitrage

**[ERROR] Tariff Rate File Path Resolution**
- Look for: relative paths in `tariff_file` config parameter
- Detection: path doesn't start with `/` or use `Path(__file__).parent`
- Fix: use `pathlib.Path` with project root: `Path(__file__).parent / "data" / "rates.csv"`

**[ERROR] Missing solver_options Defaults**
- Look for: `solver_options={}` or missing keys in solve() call
- Required keys: `timeout` (default 300), `mip_gap` (default 0.01), `threads` (default 4)
- Fix: merge with defaults: `{**DEFAULT_SOLVER_OPTS, **user_opts}`

**[WARNING] Holiday Handling**
- Look for: `holiday_calendar` in config. If absent, only federal holidays apply
- Risk: TOU periods wrong on state holidays -> incorrect billing
- Fix: add `custom_holidays` list to config

**[WARNING] Solver Exit Code**
- Look for: exit code checking in result handling
- Detection: `if result.solver.status != "ok"` without checking solution quality
- Fix: check both `result.solver.status` AND `result.solver.termination_condition`

**[INFO] Validation Thresholds**
- Look for: hardcoded assertion thresholds (e.g., `assert abs(diff) < 0.01`)
- Suggestion: make configurable via `validation_tolerance` parameter

### Step 4: Output Structured Review

Format:
```
## BTM-Optimize Validation Review

**Submission:** [description]

---

### Summary
- Total checks: N
- Errors found: N
- Warnings found: N
- Info notes: N

---

### Findings

#### [ERROR] Finding Title
**Location:** [file/line or section]
**Issue:** [description]
**Recommendation:** [how to fix]

#### [WARNING] Finding Title
...

#### [INFO] Finding Title
...

---

### Overall Rating
- **PASS** - No errors, ready for use
- **PASS_WITH_WARNINGS** - No errors, but address warnings
- **FAIL** - Critical errors must be fixed before use

---

### Next Steps
[Specific actionable items]
```

### Example Finding

```
#### [ERROR] Battery SOC Initialization Missing
**Location:** config.yaml:12, Battery class init
**Issue:** No `initial_soc` in config. Defaults to 50%.
  For peak-shaving scenarios this causes over-discharge in hour 1.
**Recommendation:** Add `initial_soc: 0.2` to config.
  Verify with: `assert config.get("initial_soc") is not None`
```

## Severity Definitions

- **ERROR**: Will cause incorrect results, crashes, or data corruption
- **WARNING**: May cause unexpected behavior in edge cases
- **INFO**: Optimization opportunity or best practice recommendation
