---
name: dnm-scenario-planner
description: Plan and manage Do-Not-Merge (DNM) scenarios for release management — create freeze windows, track blocked PRs, and coordinate merge holds across teams.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [dnm, release-management, merge-freeze, deployment, gitflow]
    related_skills: [dnm-release-pipeline, dnm-data-expert]
    category: release-management
prerequisites:
  commands: [python3, git]
  python_packages: [pyyaml, requests]
---

# DNM Scenario Planner

Plan and manage Do-Not-Merge (DNM) scenarios for release management. Create freeze windows, track blocked PRs, and coordinate merge holds across development teams.

## When to Use

- User needs to create a merge freeze for an upcoming release
- User wants to block PRs from merging due to critical issues
- User needs to plan a security embargo window
- User wants to coordinate feature flag synchronization holds
- User needs to communicate DNM status to development teams

## Key Concepts

- **Scenario**: A defined time window with a specific DNM reason (release freeze, critical bug, security hold)
- **Scope**: Repository, organization, or branch-level application of the scenario
- **Rules**: Criteria for automatically applying DNM labels or blocking merges
- **Notifications**: Communication templates for informing teams about DNM status

## Supported Scenario Types

| Type | Description | Typical Duration |
|------|-------------|------------------|
| `release-freeze` | Pre-release code freeze | 1-7 days |
| `critical-bug` | Critical issue investigation | Hours to days |
| `security-hold` | Security embargo | Variable |
| `feature-freeze` | Feature flag coordination | 1-3 days |
| `maintenance` | Infrastructure maintenance | Hours |

## Workflow

### 1. Create a DNM Scenario

Use the script to create a new scenario:

```bash
python3 ~/.hermes/skills/dnm-scenario-planner/scripts/dnm_manager.py create \
  --type release-freeze \
  --name "v2.5.0 Release Freeze" \
  --start "2026-03-25T00:00:00Z" \
  --end "2026-03-27T23:59:59Z" \
  --repos "org/repo1,org/repo2" \
  --reason "Final QA validation for v2.5.0 release"
```

### 2. Apply DNM Labels

Automatically label open PRs:

```bash
python3 ~/.hermes/skills/dnm-scenario-planner/scripts/dnm_manager.py apply-labels \
  --scenario-id scenario-uuid \
  --platform github \
  --token $GITHUB_TOKEN
```

### 3. Generate Status Report

Check current DNM status across repositories:

```bash
python3 ~/.hermes/skills/dnm-scenario-planner/scripts/dnm_manager.py status \
  --repos "org/repo1,org/repo2"
```

### 4. Lift DNM (End Scenario)

When the scenario expires or is manually resolved:

```bash
python3 ~/.hermes/skills/dnm-scenario-planner/scripts/dnm_manager.py resolve \
  --scenario-id scenario-uuid \
  --remove-labels
```

## Python API

```python
from dnm_scenario import DNMScenario, ScenarioManager

# Create a scenario
scenario = DNMScenario(
    scenario_type="release-freeze",
    name="v2.5.0 Release Freeze",
    start_time="2026-03-25T00:00:00Z",
    end_time="2026-03-27T23:59:59Z",
    repositories=["org/repo1", "org/repo2"],
    reason="Final QA validation"
)

# Save scenario
manager = ScenarioManager(storage_path="~/.hermes/dnm-scenarios/")
scenario_id = manager.create(scenario)

# Check if merges should be blocked
if manager.is_active(scenario_id):
    print(f"Merges blocked: {scenario.reason}")
```

## Templates

Use notification templates for team communication:

- `templates/dnm_notice.md` — General DNM announcement
- `templates/release_freeze.md` — Release freeze specific
- `templates/critical_bug.md` — Critical bug hold
- `templates/security_hold.md` — Security embargo notice

## Storage

Scenarios are stored as YAML files in `~/.hermes/dnm-scenarios/`:

```yaml
scenario_id: dnm-20260325-abc123
type: release-freeze
name: v2.5.0 Release Freeze
status: active
created_at: "2026-03-25T00:00:00Z"
start_time: "2026-03-25T00:00:00Z"
end_time: "2026-03-27T23:59:59Z"
repositories:
  - org/repo1
  - org/repo2
reason: Final QA validation for v2.5.0 release
created_by: Hermes Agent
```

## Auto-Lift Expired Scenarios

Run periodically (or add to a daily cron) to resolve expired freeze windows:
```bash
python3 ~/.hermes/skills/dnm-scenario-planner/scripts/dnm_manager.py cleanup \
  --auto-resolve-expired \
  --remove-labels \
  --token $GITHUB_TOKEN
```

This will:
1. Find all scenarios past their `end_time`
2. Remove DNM labels from associated PRs
3. Set scenario status to `resolved`
4. Log the auto-resolution

For CI/CD enforcement, add a GitHub Actions check:
```yaml
# .github/workflows/dnm-check.yml
- name: Check DNM freeze
  run: |
    python3 -c "
    from dnm_scenario import ScenarioManager
    mgr = ScenarioManager('~/.hermes/dnm-scenarios/')
    active = [s for s in mgr.list() if mgr.is_active(s)]
    if active:
        print(f'BLOCKED: {len(active)} active DNM scenarios')
        exit(1)
    "
```

## Limitations

- Requires repository admin access to apply DNM labels
- Does not directly block merges (relies on CI/CD integration above)
- GitHub API rate limits apply (5000 req/hr with token)
- Scenarios stored locally at `~/.hermes/dnm-scenarios/`; team sharing requires git or shared drive

## Pitfalls

- **Time zones**: Always use UTC timestamps in scenarios
- **Expired scenarios**: Run `cleanup --auto-resolve-expired` daily or expired freezes persist
- **Label conflicts**: Use `DNM:` prefix (e.g., `DNM: v2.5.0 Release Freeze`) to avoid conflicts
- **Token permissions**: GitHub token needs `repo` scope for private repositories

## Validated With

Tested with Python 3.11+, PyYAML 6.0+, and GitHub API v3.
