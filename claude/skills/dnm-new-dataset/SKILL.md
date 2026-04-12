---
name: dnm-new-dataset
description: >
  Scaffold a new dataset for the Dynamic Network Model. Use when the user wants
  to add a new CSV dataset to SP&L, including the generator function, loader
  function, and validation checks. Provides templates that match the existing
  codebase patterns exactly.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
user-invocable: true
metadata:
  author: SGridworks
  version: 1.0.0
  category: scaffolding
  tags: [dnm, spl, dataset, generator, loader, validation, template]
---

# DNM New Dataset Scaffolding

Adds a new CSV dataset to the Dynamic Network Model following exact existing patterns.

Templates are in `templates/` -- read them for the exact code patterns.

## Checklist

When adding a new dataset, you must update 3 files:

### 1. Generator (`demo_data/generate_demo_data.py`)
- Add a new `generate_<name>()` function before `main()`
- Call it in `main()` after existing generators
- Follow the pattern: print status, define headers, build rows, call write_csv(), return rows
- Use existing data (feeders, customers, transformers) as input for referential integrity

### 2. Loader (`demo_data/load_demo_data.py`)
- Add a new `load_<name>()` function
- Add it to the `loaders` dict in `load_all()`
- Follow the pattern: read_csv, parse_dates if applicable, set_index, return df

### 3. Validator (`validate_demo_data.py`)
- Load the new dataset from `d["<name>"]`
- Add row count check (use None for dynamic counts)
- Add referential integrity checks (check_fk for all foreign keys)
- Add value range checks (physical bounds)
- Add hierarchy consistency checks if the dataset has customer_id

### 4. Regenerate and Verify
```bash
cd /Users/2agents/Projects/Dynamic-Network-Model
python3 demo_data/generate_demo_data.py
/Users/2agents/btm-optimize/.venv/bin/python3 validate_demo_data.py
```

## Inline Templates

### Generator function (add to generate_demo_data.py)
```python
def generate_weather_data(substations: list[dict]) -> list[dict]:
    """Hourly weather data per substation for 1 year."""
    print("Generating weather data...")
    headers = ["substation_id", "timestamp", "temperature_f", "irradiance_w_m2", "wind_speed_mph"]
    rows = []
    for sub in substations:
        for hour in range(8760):  # 1 year of hours
            month = (hour // 720) % 12 + 1
            base_temp = 70 + 25 * math.sin((month - 1) * math.pi / 6)  # Phoenix seasonal
            rows.append({
                "substation_id": sub["substation_id"],
                "timestamp": f"2024-01-01T{hour % 24:02d}:00:00",
                "temperature_f": round(base_temp + random.gauss(0, 5), 1),
                "irradiance_w_m2": max(0, round(800 * math.sin(max(0, (hour % 24 - 6)) * math.pi / 12) + random.gauss(0, 50))),
                "wind_speed_mph": round(max(0, random.gauss(8, 4)), 1),
            })
    write_csv("weather_data", headers, rows)
    return rows
```
In `main()`: `weather = generate_weather_data(substations)`

### Loader function (add to load_demo_data.py)
```python
def load_weather_data() -> pd.DataFrame:
    df = pd.read_csv(DATA_DIR / "weather_data.csv.gz", parse_dates=["timestamp"])
    return df.set_index("substation_id")
```
In `load_all()`: `"weather_data": load_weather_data`

### Validator checks (add to validate_demo_data.py)
```python
weather = d["weather_data"]
checks.append(("weather_data row count", len(weather) > 0, f"{len(weather)} rows"))
checks.append(check_fk("weather_data", weather, "substation_id", substations))
checks.append(("weather temp range", weather["temperature_f"].between(0, 130).all(), "0-130F"))
checks.append(("weather irradiance range", weather["irradiance_w_m2"].between(0, 1200).all(), "0-1200 W/m2"))
```

## Debugging FK Errors

If `check_fk` fails with referential integrity errors:
```python
# Find orphaned IDs
weather_ids = set(weather["substation_id"].unique())
valid_ids = set(substations.index)
orphans = weather_ids - valid_ids
print(f"Orphaned IDs: {orphans}")
```

Common causes:
- Generator uses wrong parent data (e.g., `feeders` instead of `substations`)
- ID format mismatch (e.g., `"S1"` vs `"S-0001"`)
- Generator called before parent data exists in `main()`

## Gotchas

1. **Seed stability** -- adding generator calls changes PRNG sequence for everything after. All data values downstream will change. This is fine (schema stays identical).
2. **Capture return values** -- if hosting_capacity or other generators need your data, capture the return in main().
3. **Index fields use zero-padded IDs** -- e.g., `f"XX-{i+1:04d}"`. Match existing patterns.
4. **Date fields** -- use `f"{year}-{month:02d}-01"` format. Loader parses with `parse_dates=`.
5. **Feeder-level vs customer-level** -- feeder-level assets don't have customer_id. Customer-level assets must carry transformer_id, feeder_id, substation_id from the customer record.
6. **V2 conversion** -- if the new dataset needs V2 format, add a convert script. Otherwise V1-only is fine.
