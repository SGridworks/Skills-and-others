# Scoring and Decision Rules

How the self-improver agent decides whether to keep or discard each experiment.

## The Decision Gate

After every experiment, exactly ONE of these outcomes applies:

### KEEP (advance branch)

The change is kept when ALL of these are true:

1. **Metric improved** -- The eval_command output is strictly better than baseline
   - For `direction: lower` targets: new value < baseline value
   - For `direction: higher` targets: new value > baseline value
2. **Test gate passed** -- The test_gate command exited with code 0
3. **Simplicity check** -- The change does not add disproportionate complexity

### DISCARD (git reset)

The change is discarded when ANY of these are true:

1. **Metric unchanged or worse** -- No improvement over baseline
2. **Test gate failed** -- Existing tests broke
3. **Complexity exceeded** -- Marginal gain with significant added complexity

### CRASH (git reset + log)

The experiment crashed when:

1. **eval_command failed** -- Non-zero exit, no metric produced
2. **Timeout exceeded** -- Experiment ran past time_budget
3. **OOM or resource exhaustion** -- System killed the process

## Simplicity Preference

Borrowed directly from Karpathy's autoresearch -- simplicity is a first-class criterion:

| Scenario | Decision |
|----------|----------|
| Small metric gain + clean, simple change | **KEEP** |
| Small metric gain + ugly/complex change | **DISCARD** |
| No metric change + code removed/simplified | **KEEP** (simplification win) |
| No metric change + code added | **DISCARD** |
| Large metric gain + moderate complexity | **KEEP** (if tests pass) |

### Complexity Heuristics

A change is "too complex" if it:
- Adds more than 50 net lines of code for < 5% metric improvement
- Introduces a new abstraction layer for a single use case
- Adds conditional logic that only applies in narrow edge cases
- Duplicates existing patterns instead of reusing them

A change is "simplifying" if it:
- Removes dead code while maintaining metric parity
- Replaces verbose patterns with idiomatic equivalents
- Consolidates duplicate logic
- Removes unnecessary indirection

## Scoring Formula

For ranking experiments in results.tsv and deciding priority:

```
score = metric_delta * direction_multiplier
```

Where:
- `metric_delta = abs(new_value - baseline_value)`
- `direction_multiplier = -1` for `direction: lower`, `+1` for `direction: higher`
- Positive score = improvement, negative = regression

## Thresholds

| Threshold | Value | Purpose |
|-----------|-------|---------|
| Minimum improvement | > 0 (any strict improvement) | Prevents noise from being kept |
| Noise floor | < 0.5% of baseline | Treat as "no change" for simplicity decisions |
| Time budget hard cap | target.time_budget seconds | Kill experiment if exceeded |
| Max consecutive failures | 5 | Switch to next target if 5 crashes/discards in a row |
| Max total experiments | target.max_experiments | Stop this target for the night |

## Results Log Format

Every experiment is logged to `results.tsv` (untracked by git):

```
commit_hash	target	metric_value	baseline_value	delta	status	description	timestamp
```

Columns:
- `commit_hash` -- The speculative commit (even if later reset)
- `target` -- Target ID from targets.md
- `metric_value` -- Measured value (0.0 if crash)
- `baseline_value` -- Value before this experiment
- `delta` -- metric_value - baseline_value (signed)
- `status` -- `keep`, `discard`, or `crash`
- `description` -- One-line summary of what was tried
- `timestamp` -- ISO 8601

## Using History to Avoid Repeats

Before each experiment, the agent MUST read results.tsv and:

1. **Never retry** an approach that was already tried and discarded/crashed
2. **Build on** approaches that were kept (compound improvements)
3. **Combine** near-misses -- if two ideas each gave small gains, try them together
4. **Escalate** -- if simple approaches are exhausted, try more radical changes
5. **Diversify** -- if the last 3 attempts were all in the same category, try a different strategy category from strategies.md
