# Battery Field Reference

Source: `btm-optimize/src/btm_optimize/models/equipment.py`
Class: `Battery(BaseModel)` -- frozen

## Fields

| Field | Type | Default | Constraint | Units | Description |
|-------|------|---------|------------|-------|-------------|
| name | str | required | -- | -- | Human-readable identifier |
| power_mw | float | required | gt=0 | MW | Max charge/discharge rate |
| energy_mwh | float | required | gt=0 | MWh | Nameplate energy capacity |
| chemistry | BatteryChemistry | LFP | enum | -- | LFP or NMC |
| charge_efficiency | float | 0.92 | (0, 1.0] | fraction | One-way charging efficiency |
| discharge_efficiency | float | 0.92 | (0, 1.0] | fraction | One-way discharging efficiency |
| min_soc_fraction | float | 0.10 | [0.0, 1.0] | fraction | Minimum state of charge |
| max_soc_fraction | float | 0.90 | [0.0, 1.0] | fraction | Maximum state of charge |
| capex_per_kwh | float | 250.0 | ge=0 | $/kWh | Installed capital cost |
| fixed_om_per_kw_yr | float | 5.0 | ge=0 | $/kW-yr | Annual fixed O&M |
| augment_threshold | float | 0.80 | (0, 1.0] | fraction | Capacity fraction triggering augmentation |
| economic_life_years | int | 20 | ge=1 | years | Project economic life |

## Computed Properties

- `duration_hours` = `energy_mwh / power_mw` (e.g., 4 MWh / 1 MW = 4-hour battery)
- `round_trip_efficiency` = `charge_efficiency * discharge_efficiency` (default: 0.92 * 0.92 = 0.8464)

## Typical Configurations

| Application | Power (MW) | Duration (hrs) | Chemistry | Notes |
|------------|-----------|---------------|-----------|-------|
| Residential | 0.005 | 2-4 | LFP | Tesla Powerwall class |
| Commercial peak shaving | 0.25-2.0 | 2-4 | LFP/NMC | C&I demand charge mgmt |
| Utility front-of-meter | 5-100+ | 2-4 | LFP | Grid-scale |
| Microgrid backup | 0.5-5.0 | 4-8 | LFP | Islanding capability |

## SP&L / DNM Field Mapping

These Battery fields map directly to `commercial_bess.csv` in the Dynamic Network Model:

| Battery Field | DNM commercial_bess Field |
|---|---|
| power_mw | power_mw |
| energy_mwh | energy_mwh |
| chemistry | chemistry |
| charge_efficiency | charge_efficiency |
| discharge_efficiency | discharge_efficiency |
| min_soc_fraction | min_soc_fraction |
| max_soc_fraction | max_soc_fraction |
| augment_threshold | augment_threshold |
| capex_per_kwh | capex_per_kwh |
