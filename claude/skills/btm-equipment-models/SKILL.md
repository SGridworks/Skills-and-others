---
name: btm-equipment-models
description: >
  Reference for BTM-Optimize equipment model field names, valid ranges, and gotchas.
  Use when writing code that references GasGenerator, Battery, or SolarArray fields,
  when mapping BTM-Optimize parameters to other systems (DNM, SP&L, external APIs),
  when reviewing equipment configurations, or when the user mentions heat rates,
  battery chemistry, forced outage rates, or solar DC/AC ratios.
allowed-tools: Read, Grep, Glob
user-invocable: true
metadata:
  author: SGridworks
  version: 1.0.0
  category: library-reference
  tags: [btm-optimize, equipment, gas-generator, battery, solar, energy]
---

# BTM-Optimize Equipment Models Reference

Equipment models live in `btm-optimize/src/btm_optimize/models/equipment.py`.
All models are frozen Pydantic BaseModels (immutable after creation).

For detailed field definitions, read `references/gas-generator.md`, `references/battery.md`, and `references/solar-array.md` in this skill directory.

## Architecture

Layer 1 (Screener) uses these models for deterministic merit-order dispatch:
**Solar -> Gas -> Battery -> Grid**. It is a simple cost calculator, not a full dispatch engine.

Layer 2 (Monte Carlo) is where the engineering drama lives -- forced outages, gas curtailments, grid failures, weather correlation.

## Quick Field Lookup

| Model | Key Fields | Source File |
|-------|-----------|-------------|
| GasGenerator | nameplate_mw, heat_rate_segments, forced_outage_rate, min_stable_level_fraction, startup_time_minutes, ramp_rate_mw_per_min | equipment.py:47-111 |
| Battery | power_mw, energy_mwh, chemistry, charge_efficiency, discharge_efficiency, min_soc_fraction, max_soc_fraction, augment_threshold | equipment.py:119-145 |
| SolarArray | capacity_mw_dc, inverter_capacity_mw_ac, tilt_deg, azimuth_deg, annual_degradation_rate | equipment.py:148-170 |

## Construction Examples

### GasGenerator (minimal valid)
```python
GasGenerator(
    name="Solar Titan 250",               # required
    nameplate_mw=21.7,                     # required
    generator_type="industrial_gas_turbine", # required: industrial_gas_turbine | reciprocating | aero_gas_turbine | heavy_frame | fuel_cell | combined_cycle
    fuel_type="natural_gas",               # required: natural_gas | biogas | hydrogen | dual_fuel
    # Optional with defaults:
    heat_rate_segments=None,               # default: 3 segments [50%/9500, 75%/8800, 100%/8500 BTU/kWh]
    forced_outage_rate=0.05,               # 0.0-1.0
    min_stable_level_fraction=0.4,         # 0.0-1.0, below this unit must shut down
    startup_time_minutes=30,
    ramp_rate_mw_per_min=2.0,
    gas_pressure_psig_required=350.0,      # >50 triggers requires_gas_compression=True
    oem_model="solar_titan_250",           # triggers OEM library lookup
)
```

### Battery (minimal valid)
```python
Battery(
    name="Site ESS",                       # required
    power_mw=5.0,                          # required
    energy_mwh=20.0,                       # required
    chemistry="LFP",                       # required: "LFP" | "NMC" (case-sensitive StrEnum)
    # Optional with defaults:
    charge_efficiency=0.92,                # 0.0-1.0 (one-way, NOT round-trip)
    discharge_efficiency=0.92,             # 0.0-1.0
    min_soc_fraction=0.1,                  # 0.0-1.0, MUST be < max_soc_fraction
    max_soc_fraction=0.9,                  # 0.0-1.0
    augment_threshold=0.8,                 # degradation trigger, not SOC
    capex_per_kwh=250.0,                   # $/kWh (not $/kW!)
)
```

### SolarArray (minimal valid)
```python
SolarArray(
    name="Rooftop PV",                     # required
    capacity_mw_dc=2.5,                    # required
    # Optional with defaults:
    inverter_capacity_mw_ac=2.0,           # DC/AC ratio = 2.5/2.0 = 1.25
    tilt_deg=25.0,
    azimuth_deg=180.0,                     # 180 = south-facing
    annual_degradation_rate=0.005,         # 0.5%/year
    capex_per_kw_dc=1200.0,               # $/kW-DC (not $/kWh!)
)
```

## Key Validation Constraints

- `min_soc_fraction < max_soc_fraction` -- API rejects if min >= max
- `charge_efficiency` and `discharge_efficiency` are EACH 0.0-1.0 (round-trip = product)
- `heat_rate_segments` loading_fraction must be ordered ascending
- `nameplate_mw > 0`, `power_mw > 0`, `energy_mwh > 0`, `capacity_mw_dc > 0`
- `chemistry` is case-sensitive: `"LFP"` not `"lfp"` or `"Lfp"`
- `capex` units differ per model: GasGen=$/kW, Battery=$/kWh, Solar=$/kW-DC

## OEM Library

OEM-specific defaults live in `btm-optimize/src/btm_optimize/data/oem_library/`:
- `industrial_gas_turbine/` -- Solar Titan, GE LM series
- `reciprocating/` -- Caterpillar, Wartsila, Jenbacher
- `aero_gas_turbine/` -- GE LM2500, Rolls-Royce
- `heavy_frame/` -- GE 7HA, Siemens SGT
- `fuel_cell/` -- Bloom Energy, FuelCell Energy

Set `oem_model` field to trigger OEM library lookup (e.g., `"solar_titan_250"`).

## Cross-System Field Mapping

When integrating BTM-Optimize with SP&L or DNM datasets:

| BTM Field | SP&L / DNM Column | Notes |
|---|---|---|
| `SolarArray.capacity_mw_dc` | `der_customers.capacity_kw` / 1000 | SP&L is kW, BTM is MW |
| `SolarArray.inverter_capacity_mw_ac` | `der_customers.inverter_kw` / 1000 | SP&L is kW |
| `SolarArray.tilt_deg` | `der_customers.tilt` | Same units |
| `SolarArray.azimuth_deg` | `der_customers.azimuth` | Same units |
| `Battery.power_mw` | `der_customers.battery_kw` / 1000 | SP&L is kW |
| `Battery.energy_mwh` | `der_customers.battery_kwh` / 1000 | SP&L is kWh |
| `Battery.chemistry` | `der_customers.battery_type` | Map: "lithium_ion" -> "LFP" or "NMC" |
| `GasGenerator.nameplate_mw` | DNM `generators.capacity_mw` | Same units |
| `GasGenerator.fuel_type` | DNM `generators.fuel` | Map: "gas" -> "natural_gas" |

**Unit conversion is the #1 source of bugs.** SP&L uses kW/kWh, BTM uses MW/MWh. Always divide by 1000.

## Gotchas

1. **Layer 1 is NOT "8760-hour dispatch"** -- describe it as a "simple cost calculator." Layer 2 is the moneyshot.
2. **Efficiency is round-trip for batteries** -- `charge_efficiency * discharge_efficiency`. Default 0.92 * 0.92 = 0.8464 RTE. Don't confuse with one-way.
3. **Heat rate segments are piecewise-linear** -- ordered by loading_fraction. Default 3 segments: 50%/9500, 75%/8800, 100%/8500 BTU/kWh. Lower heat rate = more efficient.
4. **min_stable_level_fraction** -- Generator cannot operate below this. Default 0.4 (40%). Below this, it must shut down. This is NOT a ramp constraint.
5. **augment_threshold** -- Battery augmentation trigger at 80% remaining capacity. This is a degradation threshold, not an SOC limit.
6. **DC/AC ratio** -- SolarArray computes this as `capacity_mw_dc / inverter_capacity_mw_ac`. If inverter is None, ratio = 1.0. Typical range 1.2-1.4.
7. **gas_pressure_psig_required** -- Distribution pressure is ~2 psig. Gas turbines need 300-500+ psig. The `requires_gas_compression` property checks if >50 psig.
8. **GasGeneratorType legacy mapping** -- Old types `gas_turbine`, `fuel_cell`, `combined_cycle` auto-map to new enum values via model_validator.
9. **capex fields use different units** -- GasGenerator: $/kW. Battery: $/kWh. SolarArray: $/kW-DC. Don't mix them.
10. **BatteryChemistry enum** -- Only `LFP` and `NMC`. These are StrEnum values, case-sensitive.
