---
name: dnm-release-pipeline
description: Enforces the 6-phase DNM SDK release workflow with quality gates. Use when preparing a DNM release, from data validation to production deployment.
metadata:
  pattern: pipeline
  steps: "4"
---

# DNM Release Pipeline

Execute each step in order. Do NOT skip steps or proceed if a step fails.

## Step 1 — Data Validation

```bash
cd /Users/2agents/Projects/Dynamic-Network-Model
/Users/2agents/btm-optimize/.venv/bin/python3 validate_demo_data.py
```

Check output for:
- Row counts: 238K customers, ~43K DERs, 36.6K transformers
- All FK checks PASS (substation -> feeder -> transformer -> customer)
- No orphaned IDs
- Value ranges within physical bounds

If validation fails: fix the generator, regenerate, re-validate. Do NOT proceed with bad data.

**GATE**: All checks PASS + user confirms "Is this the complete dataset you want released?"

## Step 2 — Power Flow Validation

```bash
cd /Users/2agents/Projects/Dynamic-Network-Model
/Users/2agents/btm-optimize/.venv/bin/python3 -c "
from demo_data.load_demo_data import load_feeders, load_hosting_capacity
feeders = load_feeders()
hc = load_hosting_capacity()
# Check hosting capacity coverage
print(f'Feeders: {len(feeders)}, HC entries: {len(hc)}')
print(f'Feeders with HC: {hc.index.nunique()}')
# Voltage range check
if 'voltage_pu' in hc.columns:
    print(f'Voltage range: {hc.voltage_pu.min():.3f} - {hc.voltage_pu.max():.3f} pu')
    assert hc.voltage_pu.between(0.95, 1.05).all(), 'VOLTAGE OUT OF RANGE'
"
```

If convergence fails on specific feeders: isolate the feeder, check topology for loops or disconnected nodes.

**GATE**: All feeders converge + user approves results

## Step 3 — SDK Assembly

```bash
cd /Users/2agents/Projects/Dynamic-Network-Model

# Bump version
# Read current from __version__.py or pyproject.toml
python3 -c "import re; v=re.search(r'version.*?(\d+\.\d+\.\d+)', open('pyproject.toml').read()); print(f'Current: {v.group(1)}')"

# Build package
python3 -m build
# or: pip install -e . --dry-run

# Generate docs
pdoc demo_data/ --output-dir docs/api/ 2>/dev/null || echo "pdoc not installed, skip API docs"
```

Package structure should include:
- `demo_data/` -- all 23 CSV datasets + loaders
- `validate_demo_data.py` -- validation script
- `pyproject.toml` -- metadata + dependencies
- `README.md` -- usage examples
- `CHANGELOG.md` -- release notes

**GATE**: Package builds clean + user confirms structure

## Step 4 — Release Checklist

```bash
# Version bump
NEW_VERSION="X.Y.Z"  # user provides

# Tag and push
cd /Users/2agents/Projects/Dynamic-Network-Model
git tag -a "v$NEW_VERSION" -m "Release $NEW_VERSION"
git push origin main --tags

# Create GitHub release
gh release create "v$NEW_VERSION" \
  --title "DNM v$NEW_VERSION" \
  --notes-file CHANGELOG.md \
  dist/*.tar.gz dist/*.whl
```

Post-release:
- Update sgridworks.com/dnm with new version number
- Draft announcement for LinkedIn (SGridWorks voice, lead with what users can DO)
- Update Notion project page: Status -> Shipped, Notes -> release summary

**Rollback if broken:**
```bash
gh release delete "v$NEW_VERSION" --yes
git tag -d "v$NEW_VERSION"
git push origin :refs/tags/v$NEW_VERSION
```

## Triggers

- "dnm release"
- "release sdk"
- "publish dnm"
- "deploy dnm"

## Gotchas

1. **No skipping gates** — Each step requires explicit user approval
2. **Data validation is critical** — Synthetic data errors propagate to all users
3. **Power flow convergence** — Must pass on all test feeders before release
4. **Version consistency** — __version__.py, CHANGELOG, and git tag must match
