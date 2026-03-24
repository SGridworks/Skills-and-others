# Scoring and Tournament Rules

How candidates are evaluated, ranked, and selected in the improvement tournament.

## Overview

Unlike greedy hill-climbing (keep/discard each change sequentially), this system uses
**tournament selection**: multiple explorers work in parallel, then an independent
evaluator verifies and ranks them. The best candidate wins.

## Tournament Phases

### 1. Qualification Gate

Every candidate must pass these checks to enter the tournament. Failure on ANY check
means automatic disqualification.

| Check | Requirement | Disqualification Reason |
|-------|-------------|------------------------|
| Scope | All changed files within target.scope.mutable | "out-of-scope changes" |
| Tests | Full test suite passes (exit 0) | "tests failed" |
| Metric | eval_command produces a valid numeric value | "metric not measurable" |
| Improvement | Metric is strictly better than baseline | "no improvement" |

### 2. Scoring

Qualified candidates are scored on three axes:

**Primary: Metric Improvement (weight: 70%)**
```
improvement_score = (verified_delta / goal_delta) * 100
```
Where:
- `verified_delta` = the independently verified improvement over baseline
- `goal_delta` = the total improvement needed to reach the stated goal
- Score of 100 = goal fully met, 50 = halfway to goal, etc.

**Secondary: Simplicity (weight: 20%)**
```
simplicity_score = 100 - min(100, lines_changed / max_reasonable_lines * 100)
```
Where:
- `lines_changed` = total lines added + removed
- `max_reasonable_lines` = 200 (changes beyond this are penalized steeply)
- Fewer lines = higher score

**Tertiary: Code Quality (weight: 10%)**

Assessed by the evaluator agent reviewing the diff:

| Score | Meaning |
|-------|---------|
| 5 | Excellent -- clean, idiomatic, well-structured |
| 4 | Good -- minor style issues only |
| 3 | Acceptable -- gets the job done |
| 2 | Poor -- hacky, but functional |
| 1 | Bad -- debug artifacts, commented code, unclear intent |

**Composite score:**
```
total = (improvement_score * 0.7) + (simplicity_score * 0.2) + (quality_score * 20 * 0.1)
```

### 3. Ranking and Tiebreaking

1. Sort candidates by `total` score descending
2. If two candidates are within **2 points** of each other:
   - Prefer the one with fewer lines changed (simplicity tiebreaker)
3. If still tied:
   - Prefer the one with higher code quality score
4. If still tied:
   - Prefer the one with fewer commits (less churn)

### 4. Winner Selection

- **Clear winner:** Highest-scoring candidate with > 2 point lead
- **Close call:** Evaluator notes the margin and flags for human attention in the report
- **No winner:** If no candidate passes qualification → "no improvement found" (honest result)

## Simplicity Preference

Simplicity is rewarded, not just tolerated:

| Scenario | Outcome |
|----------|---------|
| Large improvement + clean code | Best possible score |
| Large improvement + messy code | Penalized on quality, may still win on metric |
| Small improvement + very clean code | May beat a messier candidate with similar metric |
| No improvement + code simplified | Does NOT qualify (metric must improve) |
| Equal improvement + fewer lines | Wins the tiebreak |

**Key difference from v1:** In the old greedy model, "no metric change + code simplified"
was a KEEP. In tournament mode, metric improvement is required to qualify. Simplification
without metric improvement is noted as an observation but does not win.

## Noise Floor

For metrics with natural variance (timing, performance):

- The evaluator runs eval_command 3 times per candidate
- Uses the **median** value
- Two candidates within **2% of baseline** of each other are considered tied
- The noise floor is calculated as: `noise = baseline * 0.02`

## Goal Progress

Each round of the tournament tracks progress toward the stated goal:

```
progress = (baseline - verified_metric) / (baseline - goal) * 100  [for direction: lower]
progress = (verified_metric - baseline) / (goal - baseline) * 100  [for direction: higher]
```

- 100% = goal met
- > 100% = exceeded goal
- < 0% = regression (should be disqualified)

If progress < 100% after a round, the orchestrator may run additional rounds with the
new baseline, up to the max rounds limit (3).

## Results Log Format

Each tournament round is logged to `.self-improve/run.json`:

```json
{
  "round": 1,
  "baseline": 47,
  "goal": 15,
  "candidates": [
    {
      "id": "candidate-1",
      "strategy": "remove-unused-imports",
      "self_reported_metric": 35,
      "verified_metric": 36,
      "delta": -11,
      "lines_changed": 42,
      "quality_score": 4,
      "total_score": 78.3,
      "status": "runner-up"
    },
    {
      "id": "candidate-2",
      "strategy": "add-type-annotations",
      "self_reported_metric": 29,
      "verified_metric": 29,
      "delta": -18,
      "lines_changed": 67,
      "quality_score": 5,
      "total_score": 85.1,
      "status": "winner"
    }
  ],
  "winner": "candidate-2",
  "new_baseline": 29,
  "progress_toward_goal": 56.25
}
```

## Using History Across Rounds

Between tournament rounds:

1. **Winning strategies** inform the next round -- spawn more explorers in that direction
2. **Failed strategies** are excluded -- do not re-assign them
3. **Close runners-up** may be combined with the winner in the next round
4. **Observations** from the evaluator feed into strategy selection
5. **Baseline updates** to the winner's verified metric for the next round
