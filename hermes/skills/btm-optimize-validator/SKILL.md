---
name: btm-optimize-validator
description: Validates BTM-Optimize (Behind-the-Meter energy optimization) simulation results against quality thresholds, constraint satisfaction, and energy balance checks.
version: 1.0.0
author: hermes-agent
license: MIT
metadata:
  hermes:
    tags: [btm, energy, optimization, validation, simulation, battery]
    related_skills: [btm-optimize-validate]
    category: engineering
prerequisites:
  python: ">=3.9"
  packages: [pandas, numpy]
  commands: [python3]
---

# BTM-Optimize Validator

Validates Behind-the-Meter (BTM) energy optimization simulation results for quality assurance.

## Purpose

BTM-Optimize simulations optimize battery storage dispatch for commercial/industrial sites. This skill validates simulation outputs to ensure:

- **Energy balance integrity** (charge/discharge conservation)
- **Constraint satisfaction** (power limits, SOC bounds)
- **Convergence quality** (solver status, objective value)
- **Data completeness** (required fields, no NaN values)

## Input Format

Simulation results should be JSON or CSV with these fields:

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | datetime | Simulation timestep |
| `power_kw` | float | Battery power (+ charge, - discharge) |
| `soc_pct` | float | State of charge (0-100%) |
| `site_load_kw` | float | Site electrical load |
| `solar_kw` | float | Solar generation |
| `grid_import_kw` | float | Grid power import |
| `grid_export_kw` | float | Grid power export |
| `tariff_usd_kwh` | float | Energy tariff rate |
| `revenue_usd` | float | Revenue per timestep |

## Usage

### CLI Validation

```bash
# Validate a simulation result file
python3 ~/.hermes/skills/btm-optimize-validator/scripts/validate.py results.json

# With custom thresholds
python3 ~/.hermes/skills/btm-optimize-validator/scripts/validate.py results.csv --tolerance 0.01 --verbose

# Generate detailed report
python3 ~/.hermes/skills/btm-optimize-validator/scripts/validate.py results.json --report validation_report.json
```

### Python API

```python
from btm_validator import BTMValidator

validator = BTMValidator(
    energy_tolerance=0.01,  # 1% energy balance tolerance
    soc_bounds=(0, 100),    # SOC limits
    power_bounds=(-1000, 1000)  # Power limits
)

results = validator.validate_file("simulation_results.json")

if results["valid"]:
    print("Validation PASSED")
else:
    print(f"Validation FAILED: {len(results['errors'])} errors")
    for error in results["errors"]:
        print(f"  - {error}")
```

## Validation Checks

### 1. Energy Balance Check
Verifies: `grid_import + solar + battery_discharge = site_load + battery_charge + grid_export`

Tolerance: ±1% by default (configurable)

### 2. SOC Bounds Check
Ensures SOC stays within physical limits (0-100% by default)

### 3. Power Bounds Check
Verifies battery power stays within rated power limits

### 4. Constraint Violations
Detects periods where:
- Charging when SOC at 100%
- Discharging when SOC at 0%
- Power exceeds ramp rate limits

### 5. Data Quality Checks
- No missing timestamps
- No NaN values in critical fields
- Monotonic timestamp ordering
- Appropriate value ranges

## Output Format

```json
{
  "valid": false,
  "summary": {
    "total_checks": 8,
    "passed": 6,
    "warnings": 1,
    "errors": 1
  },
  "errors": [
    {
      "check": "energy_balance",
      "severity": "error",
      "message": "Energy imbalance exceeds tolerance at 3 timesteps",
      "details": [...]
    }
  ],
  "warnings": [
    {
      "check": "soc_bounds",
      "severity": "warning", 
      "message": "SOC near lower bound for 5% of simulation"
    }
  ],
  "metrics": {
    "total_energy_mwh": 1250.5,
    "avg_cycle_depth_pct": 45.2,
    "total_revenue_usd": 45230.15
  }
}
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Validation passed |
| 1 | Validation failed (errors found) |
| 2 | File not found or unreadable |
| 3 | Invalid input format |

## Configuration

Create `~/.btm-validator.yaml` for default settings:

```yaml
energy_tolerance: 0.01
soc_bounds: [0, 100]
power_bounds: [-1000, 1000]
required_fields:
  - timestamp
  - power_kw
  - soc_pct
  - site_load_kw
```
