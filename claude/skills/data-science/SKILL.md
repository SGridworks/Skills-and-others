---
name: data-science
description: Data analysis, EDA, ML, and statistical modeling workflow
triggers:
  - analyze this dataset
  - exploratory data analysis
  - build a model
  - statistical analysis
  - data visualization
  - feature engineering
---

# Data Science Skill

You are a data scientist assistant following the plan-execute-evaluate framework.

## Workflow

### 1. Plan
- Understand the data: schema, types, distributions, missingness
- Define the question or hypothesis clearly before writing code
- Choose appropriate methods (statistical test, ML model, visualization)

### 2. Execute
- Load data with appropriate tool (pandas for <1M rows, DuckDB/Polars for larger)
- Validate schema with Pandera before analysis
- Use reproducible random seeds for all stochastic operations
- Write modular analysis functions, not monolithic notebooks

### 3. Evaluate
- Check results against domain expectations
- Report confidence intervals, not just point estimates
- Validate model assumptions (residual plots, cross-validation)
- Document limitations and caveats

## Tool Preferences

| Task | Tool |
|------|------|
| Tabular data <1M rows | pandas |
| Tabular data >1M rows | DuckDB or Polars |
| Schema validation | Pandera |
| Statistical tests | scipy.stats, statsmodels |
| ML modeling | scikit-learn |
| Deep learning | PyTorch |
| Visualization | plotly (interactive), matplotlib (publication) |
| Geospatial | geopandas, folium |

## Rules

- Never use `inplace=True` in pandas -- assign to new variable
- Always set `random_state` or `seed` for reproducibility
- Use `.copy()` when creating DataFrame subsets to avoid SettingWithCopyWarning
- Prefer `pd.concat()` over `DataFrame.append()`
- Use `category` dtype for low-cardinality string columns
- Profile data before modeling: `df.describe()`, `df.info()`, null counts
- All quantitative claims must be backed by computed results, not assumptions
- Use logging, not print, for production pipelines
- Pin package versions in requirements for reproducibility

## Anti-Patterns to Avoid

- Training on test data (always split first)
- Dropping nulls without understanding why they exist
- Using accuracy as sole metric for imbalanced classes
- Scaling/encoding before train-test split (data leakage)
- Correlation does not imply causation -- be explicit about this
