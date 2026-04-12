---
name: nightly-self-evolution
description: Autonomous overnight quantitative testing and self-improvement pipeline for Hermes Agent
category: autonomous
tags: [agent, self-improvement, testing, local-llm]
---

# Nightly Self-Evolution

Autonomous overnight quantitative testing and self-improvement pipeline for Hermes Agent.

**Research foundation:** Reflexion (Shinn et al. 2023), Self-Refine (Madaan et al. 2023), Eureka (OpenAI 2023), Agentic Skill Discovery (2024).

## Core Philosophy

Apply the **Reflexion** loop to Hermes tools:

1. **Act** — Run quantitative tests against real tool files
2. **Observe** — Capture exact failure modes with stack traces
3. **Reflect** — Use gemma3:12b to diagnose root cause from actual error data
4. **Adapt** — Generate targeted patches against real file paths and line numbers
5. **Verify** — Re-run tests immediately to confirm fix works before reporting

Key insight from Reflexion: verbal reflection against real error data produces better fixes than abstract analysis. Self-Refine adds iterative feedback — same model generates, critiques, refines. Eureka shows LLM-written patches validated against the actual system outperform human-engineered fixes.

## What It Does

Runs every night at 7PM ET. Uses local models (gemma3:12b) to:

1. Scan arXiv, Hacker News, and Lobste.rs for AI agent community intelligence
2. Run quantitative tests against REAL hermes-agent tool files (not hypothetical)
3. Capture actual failure output (stack traces, error messages, exit codes)
4. Diagnose root cause from real errors using gemma3:12b
5. Generate targeted patches against actual file paths and line numbers
6. Verify fixes by re-running tests immediately (Eureka-style validation)
7. Deliver morning report with exact diffs at 7AM ET

## Architecture

```
7PM: Cron triggers overnight process
  │
  ├─► PHASE 0: Social Scan
  │     ├─► arXiv (REST API — free, no key) — recent AI agent papers
  │     ├─► Hacker News (Firebase API — top 50 stories)
  │     ├─► Lobste.rs (RSS — top 20 stories)
  │     └─► gemma3:12b synthesis → trends, warnings, opportunities
  │
  ├─► PHASE 1: Parallel Tool Testing (Reflexion Act phase)
  │     ├─► TEST AGENT 1: File tools — actual tools/file_tools.py
  │     ├─► TEST AGENT 2: Terminal tool — actual tools/terminal_tool.py
  │     ├─► TEST AGENT 3: Web tools — actual tools/web_tools.py
  │     ├─► TEST AGENT 4: Code execution — actual tools/code_execution_tool.py
  │     └─► TEST AGENT 5: Agent core — actual run_agent.py, model_tools.py
  │     Each agent: designs tests AND executes them, captures real output
  │
  ├─► PHASE 2: Failure Analysis (Reflexion Observe phase)
  │     Feed actual stdout/stderr from Phase 1 into gemma3:12b
  │     Output: root cause per failing test with exact file:line references
  │
  ├─► PHASE 3: Patch Generation (Reflexion Adapt phase)
  │     Targeted patches against real paths, validated by re-running tests
  │     Eureka-style: if test passes after patch, the patch is correct
  │
  └─► 7AM: Morning Report → Telegram
        - Community intelligence (trends, warnings, opportunities)
        - Actual test results with pass/fail counts
        - Targeted patches with file:line references
        - Verification results (test ran after patch = confirmed fix)
```

## Key Differences from V1

| V1 (broken) | V2 (fixed) |
|-------------|------------|
| Phase 1 designs tests, never runs them | Phase 1 designs AND executes tests, captures real output |
| Phase 3 patches hypothetical files | Phase 3 patches actual file paths from Phase 1 errors |
| Phase 4 runs unrelated static tests | Phase 4 re-runs the SAME tests from Phase 1 to verify |
| Social scan uses DuckDuckGo (blocked) | Social scan uses arXiv + HN + Lobste.rs (free, works) |
| Patches accepted blindly | Eureka-style: test must pass after patch = validated |

## Models

- **Primary:** gemma3:12b on mini2 Ollama (10.0.5.2:11434) -- analysis, fix generation, coordination
- **Embeddings:** nomic-embed-text on mini2 Ollama -- similarity search for failure pattern matching
- **Fallback:** Kimi K2.5 (cloud) if Ollama is down or model OOMs
- All local inference preferred -- zero API cost. Cloud fallback adds ~$0.01/run.

**Model check before run:**
```bash
curl -s http://10.0.5.2:11434/api/tags | python3 -c "
import sys,json
models = [m['name'] for m in json.load(sys.stdin).get('models',[])]
if 'gemma3:12b' not in ' '.join(models):
    print('WARNING: gemma3:12b not available, will fall back to Kimi K2.5')
else:
    print('OK: gemma3:12b available')
"
```

## Output Location

`~/.hermes/nightly_runs/YYYYMMDD/`

```
YYYYMMDD/
├── social_scan/              # Phase 0: arXiv + HN + Lobste.rs
│   ├── raw.json
│   └── synthesis.json       # Trends, warnings, opportunities
├── test_runs/               # Phase 1: actual test output per area
│   ├── file_tools.json
│   ├── terminal_tool.json
│   └── ...
├── failure_analysis/         # Phase 2: root cause from REAL errors
│   └── diagnoses.json
├── fixes/                   # Phase 3: targeted patches (verified)
│   ├── applied/             # Auto-applied, test confirmed passing
│   └── needs_review/        # Manual review required
├── novel_approaches/        # Experimental changes tried
└── morning_report.md        # Human-readable summary
```

## Fix Policy

| Type | Action | Verification |
|------|--------|--------------|
| Typo / dead code | Auto-patch + verify | Test must re-pass |
| Missing import | Auto-patch + verify | Test must re-pass |
| Test data staleness | Auto-update + verify | Test must re-pass |
| Logic bug | Patch + isolate test | Adam reviews |
| Novel approach | Experimental branch | Adam reviews |
| Config error | Flag | Adam reviews |

## Revert Strategy

If a patch breaks tests that were previously passing:
```bash
cd ~/hermes-agent
git stash  # save the broken patch
# Re-run the specific test that broke
python -m pytest tests/ -x --tb=short
# If still broken after stash:
git log --oneline -5  # find last known good commit
git checkout <good-commit> -- <broken-file>
```

For auto-applied patches (typos, imports, dead code):
- Each patch is committed separately with message: `fix(nightly): <description>`
- Revert with: `git revert <commit-hash>`

For experimental branch patches:
- Always on branch `nightly/YYYYMMDD`, never on main
- Delete failed branches: `git branch -D nightly/YYYYMMDD`

## Disk Cleanup

Nightly runs accumulate at `~/.hermes/nightly_runs/`. Policy:
- Keep last 14 days of runs
- Auto-clean on startup:
```bash
find ~/.hermes/nightly_runs/ -maxdepth 1 -type d -mtime +14 -exec rm -rf {} +
```

## Success Metrics

- Pass rate before vs after (verified, not estimated)
- Time-to-fix per failure category
- Repeat failure rate over 7 days
- Novel approaches introduced and validated

## Trigger

```bash
python ~/.hermes/skills/nightly-self-evolution/scripts/run_overnight.py --now
```

Runs via cron at 7PM ET daily (set up via `--setup-cron`).

## Tool Areas Tested (Priority Order)

1. **file_tools** — tools/file_tools.py: read_file, write_file, patch, search_files
2. **terminal_tool** — tools/terminal_tool.py: shell, background processes
3. **web_tools** — tools/web_tools.py: search, extract, browser_navigate
4. **code_execution** — tools/code_execution_tool.py: sandbox, delegate
5. **agent_core** — run_agent.py, model_tools.py: tool routing, compression
