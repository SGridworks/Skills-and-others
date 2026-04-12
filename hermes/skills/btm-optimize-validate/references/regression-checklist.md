# BTM-Optimize Regression Checklist

## [ERROR] Battery SOC Initialization
- **Problem:** Defaults to 50%, should be user-defined
- **Check:** Verify SOC initial value in config
- **Fix:** Add explicit `initial_soc` parameter
- **Where to look:** Config dict, Battery class initialization

## [ERROR] Tariff Rate File Path Resolution
- **Problem:** Resolves relative to CWD, not project root
- **Check:** Verify rate file loads from correct path
- **Fix:** Use absolute paths or project-relative paths
- **Where to look:** `load_rates()`, `tariff_file` parameter usage

## [ERROR] Missing solver_options Defaults
- **Problem:** solver_options dict missing required keys
- **Check:** Verify all required solver options present
- **Fix:** Add defaults for timeout, mip_gap, etc.
- **Where to look:** `solve()` method, `solver_options` parameter

## [WARNING] Holiday Handling Edge Cases
- **Problem:** Only federal holidays, not state/local
- **Check:** Verify holiday calendar matches jurisdiction
- **Fix:** Allow custom holiday lists
- **Where to look:** `holiday_calendar` config, tariff time-of-use calculations

## [WARNING] Solver Exit Code Interpretation
- **Problem:** Exit code 1 = infeasible, but sometimes just warning
- **Check:** Parse solver log for actual status
- **Fix:** Check both exit code and solution quality
- **Where to look:** Solver wrapper, result validation logic

## [INFO] Validation Threshold Sensitivity
- **Note:** Default validation thresholds may be too strict
- **Suggestion:** Allow per-scenario threshold override
- **Where to look:** `validate_results()`, assertion thresholds
