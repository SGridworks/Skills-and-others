---
name: auto-optimize
description: |
  Karpathy's auto-research loop: make a change, test, measure, keep or discard, repeat.
  Use when user says "optimize X", "tune Y", "run experiments on Z", "auto-tune",
  or "let it run overnight and show me results". Works for any system with a
  measurable metric and a configurable variable the agent can change.
---

# Auto-Optimize: Self-Improving Experiment Loop

Based on Andrej Karpathy's auto-research pattern. Simple loop: change, test,
measure, keep or discard, repeat.

## The Three Requirements

Before starting, confirm:
1. **A metric to track** — something objective (error rate, latency, cost, revenue)
2. **A feedback loop** — the test must run fast enough to iterate (5min = great, 1hr = acceptable)
3. **Agent autonomy** — the agent must be able to change the variable without manual steps

If any requirement is missing, ask the user before proceeding.

## The Loop

```
WHILE experiments_remaining > 0:
  1. Propose a small change to the variable
  2. Run the test → get metric value
  3. Compare against current best
  4. IF better → keep change, update baseline
  5. ELSE → discard, try different change
  6. Log: iteration, change, metric, decision
  7. experiments_remaining -= 1
```

## Pre-Flight Checklist

Run before starting:

```
[ ] Metric defined: <metric_name> (lower/higher is better)
[ ] Baseline established: <current_value>
[ ] Test command: <exact command to run>
[ ] Variable to change: <what agent modifies>
[ ] Search space: <min/max or enumerated options>
[ ] Max iterations: <N>
[ ] Output file: ./auto_optimize_results.jsonl
```

## Experiment Log Format

Every iteration writes one JSON line to `./auto_optimize_results.jsonl`:

```json
{"iteration": 1, "change": "reorder_point=55", "metric": "stockout_count", "value": 3, "baseline": 7, "delta": -4, "decision": "keep"}
{"iteration": 2, "change": "reorder_point=60", "metric": "stockout_count", "value": 5, "baseline": 3, "delta": 2, "decision": "discard"}
```

## Running the Loop

### Single-session (manual trigger)

Tell the user: "Running N experiments. I'll report every 10 iterations with winners."

```bash
mkdir -p ./auto_optimize_logs
echo "iteration,change,metric,value,baseline,delta,decision" > ./auto_optimize_results.csv
```

Then run the loop — log each iteration with terminal output:

```
[iter 1/50] reorder_point=55 → stockout_count=3 (baseline=7, -4, KEEP)
[iter 2/50] reorder_point=60 → stockout_count=5 (baseline=3, +2, DISCARD)
...
```

Report summary every 10 iterations:
- What worked
- What didn't
- Current best setting
- Projected time to completion

### Overnight / scheduled (background)

Best for slow feedback loops (hours/days).

Run as a background process with nohup:
```bash
nohup python3 -c "
import json, subprocess, time

# Configure
config = {
    'metric': 'monthly_bill_estimate',
    'variable': 'tier_threshold_kwh',
    'search_space': list(range(200, 800, 25)),
    'max_iterations': 50,
    'test_cmd': 'python lib/simulate.py --config /tmp/tune_config.json'
}

best = (None, float('inf'))
results = []

for i, val in enumerate(config['search_space'][:config['max_iterations']]):
    try:
        result = subprocess.run(config['test_cmd'].split(), capture_output=True, text=True, timeout=600)
        if result.returncode != 0:
            print(f'[iter {i+1}] ERROR: {result.stderr[:100]}')
            continue
        score = float(result.stdout.strip().split()[-1])
        decision = 'keep' if score < best[1] else 'discard'
        if score < best[1]:
            best = (val, score)
        results.append({'iteration': i+1, 'change': val, 'value': score, 'decision': decision})
        print(f'[iter {i+1}] {val} -> {score:.2f} [{decision}]')
    except subprocess.TimeoutExpired:
        print(f'[iter {i+1}] TIMEOUT at {val}')
        continue

with open('./auto_optimize_results.jsonl', 'w') as f:
    for r in results:
        f.write(json.dumps(r) + '\n')
print(f'DONE. Best: {best}')
" > ./auto_optimize.log 2>&1 &
echo "Running in background. PID: $!"
echo "Monitor: tail -f ./auto_optimize.log"
```

## Change Strategies

When to use each:

| Strategy | When | Example |
|----------|------|---------|
| Random walk | Small search space (<20 options) | Try reorder_point: 45, 50, 55, 60, 65 |
| Gradient ascent | Continuous, smooth metric | Binary search toward optimal threshold |
| Opposition-based | Structured reordering | If 55 failed, try 70 (opposite direction) |
| Ensemble | Multiple independent vars | Grid search over (threshold, multiplier) pairs |

## Post-Run: Skill Distillation

After a successful run (>10 iterations), offer to distill the winning
strategy into a reusable skill:

```
"Found reorder_point=55 minimizes stockouts. Want me to save this as a
btm-inventory-tune skill so you can run it anytime without re-specifying
the loop? Takes 2 minutes."
```

Save the winning config to a file for reuse:
```bash
cat > ~/.hermes/skills/auto-optimize/presets/<name>.json << 'EOF'
{"variable": "<var>", "best_value": <val>, "metric": "<metric>", "score": <score>}
EOF
```

## Output Summary Template

After run completes:

```
## Auto-Optimize Results

**Metric:** <metric_name> (<direction>)
**Best value:** <winning_setting>
**Best score:** <value>
**Improvement:** <pct>% vs baseline
**Iterations:** <N>
**Duration:** <elapsed>

### Winners
| Setting | Score | vs Baseline |
|---------|-------|-------------|
| reorder_point=55 | 3 | -57% |

### Losers
| Setting | Score | vs Baseline |
|---------|-------|-------------|
| reorder_point=60 | 5 | -29% |

Run again? Same setup or new search space?
```
