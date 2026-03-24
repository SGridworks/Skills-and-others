# Prompt for Hermes

## Context

The `Skills-and-others` repo now has a new autonomous self-improvement skill at `claude/skills/self-improve/`. This skill lets Claude Code optimize any measurable aspect of a codebase overnight without human intervention.

## How It Works

The system uses **purpose-driven tournament selection** — not greedy hill-climbing:

1. **Define purpose** — Start with WHY (e.g., "reduce lint warnings so CI noise is lower"), set an explicit goal (e.g., "< 15 warnings"), capture a baseline
2. **Spawn explorers** — 2-5 explorer agents work in parallel, each in an isolated worktree, each pursuing a different strategy
3. **Tournament** — An independent evaluator agent re-runs every metric, disqualifies broken candidates, ranks the rest by improvement (70%) + simplicity (20%) + code quality (10%)
4. **Pick winner** — Best verified candidate gets merged. If the goal isn't met, iterate (up to 3 rounds)
5. **Report** — Draft PR with full results for human review

## Key Files

| File | What It Does |
|------|-------------|
| `claude/skills/self-improve/SKILL.md` | Orchestration — the 8-phase flow |
| `claude/agents/self-improver.md` | Explorer agent — implements one strategy, reports results |
| `claude/agents/evaluator.md` | Judge agent — verifies candidates independently, runs tournament |
| `claude/skills/self-improve/references/scoring.md` | Scoring formula and tournament rules |
| `claude/skills/self-improve/references/targets.md` | Target registry (test-speed, lint-warnings, etc.) with purpose statements |
| `claude/skills/self-improve/references/strategies.md` | Strategy catalog organized by risk tier (A/B/C) |

## What I Need From You

1. **Review the architecture** — Does the purpose → explore → tournament → iterate flow make sense? Are there gaps in the handoff between explorers and evaluator?

2. **Stress-test the targets** — Each target in `references/targets.md` has a purpose statement, goal strategy, eval_command, and suggested explorer assignments. Are the eval_commands robust? Are the scopes too broad or too narrow?

3. **Validate the scoring** — The tournament scoring in `references/scoring.md` weights metric improvement at 70%, simplicity at 20%, quality at 10%. Does this balance feel right? Should the noise floor (2% of baseline) be different for different metric types?

4. **Test with a real repo** — Try running `/self-improve shellcheck-issues` or `/self-improve lint-warnings` against a real project and see where it breaks.

5. **Suggest new targets** — What other measurable aspects of codebases would benefit from this approach? (e.g., dependency staleness, API response time, memory usage)

## Design Decisions Worth Discussing

- **Explorers can't grade themselves** — The evaluator re-runs every metric independently. This prevents measurement gaming but adds overhead. Worth it?
- **No "simplification-only" wins** — In v1, removing code with no metric change was a KEEP. In v2, metric improvement is required to qualify. Simplification is rewarded via the scoring weight but can't win alone.
- **3 round cap** — Prevents runaway loops but might not be enough for ambitious goals. Should this be configurable per target?
- **Ad-hoc targets** — Users can pass free-form purposes like "make our API tests less flaky" and the skill constructs a target on the fly. This is powerful but fragile — needs validation.
