---
name: spl-data
description: >
  Load and analyze Sisyphean Power & Light distribution data. Use when the user
  asks about SP&L data, wants to explore feeders/transformers/customers/DER,
  needs to join datasets, build feeder-level summaries, analyze hosting capacity,
  or work with any of the 23 DNM datasets. Also use when building notebooks or
  doing data exploration on the Dynamic Network Model.
allowed-tools: Read, Grep, Glob, Bash
user-invocable: true
metadata:
  author: SGridworks
  version: 1.0.0
  category: data-analysis
  tags: [spl, dnm, distribution, utility, data, analysis, energy]
---

# SP&L Data Analysis Skill

23 datasets for Sisyphean Power & Light, a fictional 238K-customer utility in Phoenix, AZ.

For the dataset index and join keys, read `references/dataset-index.md`.
For composable helper functions, read `scripts/load_helpers.py`.

## Quick Start

```python
from demo_data.load_demo_data import load_all, summary

# See everything available
summary()

# Load all 23 datasets
data = load_all()

# Load specific datasets (faster)
from demo_data.load_demo_data import load_substations, load_feeders, load_hosting_capacity
```

## Project Path

All code runs from: `/Users/2agents/Projects/Dynamic-Network-Model/`

Use the btm-optimize venv for pandas/numpy:
```bash
/Users/2agents/btm-optimize/.venv/bin/python3
```

## V1 vs V2

- **V1** (`demo_data/`): CSV files, always available, 23 datasets
- **V2** (`sisyphean-power-and-light/`): Restructured with parquet, column renames. Auto-detected by loader.

When V2 is present, some loaders read from V2 and rename columns. For analysis, always use the `load_*()` functions -- never read CSVs directly.

## Common Analysis Patterns

Always use this python for SP&L work:
```bash
/Users/2agents/btm-optimize/.venv/bin/python3
```

### DER capacity by feeder with hosting utilization
```python
import sys; sys.path.insert(0, '/Users/2agents/Projects/Dynamic-Network-Model')
from demo_data.load_demo_data import load_der_customers, load_hosting_capacity, load_feeders

der = load_der_customers()
hc = load_hosting_capacity()
feeders = load_feeders()

# Aggregate DER to feeder level
der_by_feeder = der.groupby('feeder_id').agg(
    total_solar_kw=('capacity_kw', 'sum'),
    total_battery_kwh=('battery_kwh', 'sum'),
    der_count=('customer_id', 'count')
).reset_index()

# Aggregate hosting capacity to feeder level (sum of transformer limits)
hc_by_feeder = hc.groupby('feeder_id')['hosting_capacity_kw'].sum().reset_index()

# Join and compute utilization
result = der_by_feeder.merge(hc_by_feeder, on='feeder_id').merge(feeders[['feeder_id','feeder_name']], on='feeder_id')
result['utilization_pct'] = (result['total_solar_kw'] / result['hosting_capacity_kw'] * 100).round(1)
result.sort_values('utilization_pct', ascending=False)
```

### Load profiles -- always filter first
```python
from demo_data.load_demo_data import load_load_profiles

# WRONG: lp = load_load_profiles()  # 1.4M rows, will be slow
# RIGHT: filter to specific feeders
import pandas as pd
lp = pd.read_csv(
    '/Users/2agents/Projects/Dynamic-Network-Model/demo_data/load_profiles.csv.gz',
    usecols=['feeder_id','hour','load_kw']
)
target_feeders = ['F001', 'F002', 'F003']
lp = lp[lp['feeder_id'].isin(target_feeders)]
```

### Adding a new dataset
For scaffolding a new dataset, use `/dnm-new-dataset` which provides generator, loader,
and validation templates. Read `references/dataset-index.md` first to understand the
column naming conventions and join key patterns.

## Gotchas

1. **Use load functions, not pd.read_csv** -- the loader handles V1/V2 detection, column renames, type casting, and index setting.
2. **Common join key hierarchy**: substation_id -> feeder_id -> transformer_id -> customer_id. Every table carries feeder_id and substation_id.
3. **Hosting capacity is per-transformer** -- 36,668 rows, one per transformer. Join on transformer_id.
4. **Community solar joins on feeder_id** (not customer_id) -- these are feeder-level assets.
5. **Microgrids also join on feeder_id** -- facility-level, not customer-level.
6. **CHP and BESS join on customer_id** -- they're customer-sited.
7. **load_profiles.csv.gz is 1.4M rows** -- filter by feeder_id before doing heavy analysis.
8. **customer_interval_data.csv.gz is 6.7M rows** -- only 500 sampled customers, but 13,440 intervals each.
