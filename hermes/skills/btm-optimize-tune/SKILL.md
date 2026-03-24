---
name: btm-optimize-tune
description: |
  Auto-tune BTM-Optimize tariff configurations using Karpathy's experiment loop.
  Optimize tier thresholds, rate multipliers, demand charges, and TOU windows.
  Use when user says "tune BTM tariffs", "optimize utility rates", "tune demand
  charges", or "run tariff experiments".
---

# BTM Tariff Auto-Tune

Optimize behind-the-meter (BTM) energy tariff configurations automatically.
The loop tests different rate structures, measures bill impact, and converges
on the lowest-cost configuration for a given profile.

## Pre-Flight

```
[ ] Load customer profile: <path or ID>
[ ] Baseline metric: monthly_bill_estimate ($/month)
[ ] Config file: <path to tariff JSON/YAML>
[ ] Tuneable variables:
    - tier_threshold_kwh (kWh breakpoints between rate tiers)
    - energy_rate [$/kWh per tier]
    - demand_rate [$/kW]
    - fixed_charge [$/month]
    - TOU windows (on-peak hours)
[ ] Max iterations: <N>
[ ] Output: ./btm_tune_results.jsonl
```

## The Loop

```
FOR each iteration until max:
  1. Propose change to 1+ variables (random walk or gradient)
  2. Run: python btm_simulate.py --config <variant> --profile <profile>
  3. Parse: monthly_bill_estimate from output
  4. Compare: vs current best
  5. Keep/discard: update baseline if improved
  6. Log: ./btm_tune_results.jsonl
```

## Change Strategies

### Strategy 1: Tier Threshold Sweep
```python
# Binary search on tier boundary
search_space = range(200, 1000, 25)  # kWh
baseline = current_tier1_threshold
while range:
  mid = (lo + hi) // 2
  test(mid)
  if better(mid): hi = mid
  else: lo = mid
```

### Strategy 2: Rate Multiplier Grid
```python
# 2D grid: energy_rate × demand_rate
for er in [0.08, 0.10, 0.12, 0.14]:
  for dr in [8, 12, 16, 20]:
    test(energy_rate=er, demand_rate=dr)
```

### Strategy 3: TOU Window Shift
```python
# Slide on-peak window
for start_hour in range(8, 18):
  test(on_peak_start=start_hour, on_peak_end=start_hour+6)
```

## Output Format

`./btm_tune_results.jsonl`:
```json
{"iteration": 1, "change": {"tier1_threshold": 400}, "metric": "monthly_bill", "value": 1847.32, "baseline": 2012.50, "delta": -165.18, "decision": "keep"}
{"iteration": 2, "change": {"tier1_threshold": 450}, "metric": "monthly_bill", "value": 1912.10, "baseline": 1847.32, "delta": 64.78, "decision": "discard"}
```

## Running

### From CLI
```bash
cd /Users/2agents/Projects/sgridworks/ops-dashboard
python -c "
import json, subprocess, itertools

# Example: tier threshold sweep
thresholds = range(200, 800, 25)
best = (None, float('inf'))
results = []

for t in thresholds:
    # Modify config
    config = json.load(open('config/tariff_default.json'))
    config['tiers'][0]['max_kwh'] = t
    
    # Run simulation
    with open('/tmp/tune_config.json', 'w') as f:
        json.dump(config, f)
    
    result = subprocess.run(
        ['python', 'lib/simulate.py', '--config', '/tmp/tune_config.json'],
        capture_output=True, text=True
    )
    bill = float(result.stdout.strip().split()[-1])
    
    decision = 'keep' if bill < best[1] else 'discard'
    if bill < best[1]:
        best = (t, bill)
    
    results.append({'threshold': t, 'bill': bill, 'best': decision})
    print(f'tier1={t} → ${bill:.2f} [{decision}]')

print(f'\nBEST: tier1={best[0]} → ${best[1]:.2f}')
"
```

### Error Handling

If the simulation crashes:
- Check stderr for Pyomo solver errors (CBC/GLPK timeout, infeasible model)
- If infeasible: revert to last known good config, skip this iteration
- If timeout: double `solver_options.timeout` and retry once
- Log crashed iterations with `"decision": "error"` in results.jsonl

```python
try:
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
    if result.returncode != 0:
        print(f"SKIP: solver error at tier1={t}: {result.stderr[:200]}")
        continue
except subprocess.TimeoutExpired:
    print(f"SKIP: timeout at tier1={t}")
    continue
```

## Results Summary

After run:
```
## BTM Tariff Tune Results

**Best config found:**
- Tier 1 threshold: 375 kWh
- Energy rate: $0.10/kWh
- Demand rate: $12/kW
- Monthly bill: $1,847.32

**Improvement:** -8.2% vs baseline ($2,012.50)
**Iterations:** 24
**Duration:** 3.2 minutes

### Top 3 Configs
| Config | Monthly Bill | vs Baseline |
|--------|-------------|-------------|
| tier1=375, er=0.10, dr=12 | $1,847 | -8.2% |
| tier1=400, er=0.10, dr=12 | $1,852 | -8.0% |
| tier1=350, er=0.11, dr=12 | $1,871 | -7.0% |

Apply best config? [y/n]
```

## Skill Distillation

After successful tune, save the winning config:
```bash
# Save best config as a named preset
cp /tmp/tune_config.json /Users/2agents/btm-optimize/configs/tuned_acme_data_center.json
echo "Saved tuned config. Re-run with: python lib/simulate.py --config configs/tuned_acme_data_center.json"
```

## Project Path

BTM-Optimize lives at: `/Users/2agents/btm-optimize/`
Use the project venv: `/Users/2agents/btm-optimize/.venv/bin/python3`

Adjust CLI paths above if the simulate script has moved. Check:
```bash
find /Users/2agents/btm-optimize -name "simulate*.py" -o -name "dispatch*.py" | head -5
```
