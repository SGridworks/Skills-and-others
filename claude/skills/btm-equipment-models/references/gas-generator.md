# GasGenerator Field Reference

Source: `btm-optimize/src/btm_optimize/models/equipment.py`
Class: `GasGenerator(BaseModel)` -- frozen

## Core Fields

| Field | Type | Default | Constraint | Description |
|-------|------|---------|------------|-------------|
| name | str | required | -- | Human-readable identifier |
| unit_type | GasGeneratorType | required | enum | reciprocating, gas_turbine_aero, gas_turbine_industrial, ccgt, ccgt_utility, fuel_cell_sofc, fuel_cell_mcfc |
| nameplate_mw | float | required | gt=0 | Rated capacity in MW |
| count | int | 1 | ge=1 | Number of identical units |
| min_stable_level_fraction | float | 0.4 | [0.0, 1.0] | Minimum operating point as fraction of nameplate |
| heat_rate_segments | list[HeatRateSegment] | 3 segments | -- | Piecewise-linear heat rate curve |
| forced_outage_rate | float | 0.03 | [0.0, 1.0] | Probability of unplanned outage (3%) |
| planned_outage_rate | float | 0.04 | [0.0, 1.0] | Fraction of time in planned maintenance (4%) |

## Financial Fields

| Field | Type | Default | Units | Description |
|-------|------|---------|-------|-------------|
| startup_cost_per_start | float | 500.0 | $/start | Cost per cold start |
| capex_per_kw | float | 1200.0 | $/kW | Installed capital cost |
| fixed_om_per_kw_yr | float | 15.0 | $/kW-yr | Annual fixed O&M |
| variable_om_per_mwh | float | 10.0 | $/MWh | Variable O&M per MWh generated |
| fuel_cost_per_mmbtu | float | 3.50 | $/MMBtu | Natural gas fuel cost |
| economic_life_years | int | 25 | years | Project economic life |

## Operational Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| ramp_rate_mw_per_min | float or None | None | MW/min ramp rate |
| startup_time_minutes | float or None | None | Minutes to reach min stable level |
| gas_pressure_psig_required | float or None | None | Required gas supply pressure |
| dual_fuel_capable | bool | False | Can run on backup fuel |
| annual_operating_hours | int | 8000 | Expected annual runtime |

## Emissions Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| co2_rate_tons_per_mmbtu | float | 0.0531 | CO2 emission rate |
| scr_equipped | bool | False | Has selective catalytic reduction |
| nox_rate_lb_per_mwh | float or None | None | NOx emission rate |
| co_rate_lb_per_mwh | float or None | None | CO emission rate |
| pm25_rate_lb_per_mwh | float or None | None | PM2.5 emission rate |
| voc_rate_lb_per_mwh | float or None | None | VOC emission rate |
| emission_control | str or None | None | Control technology name |
| emission_control_capex_per_kw | float | 0.0 | Additional capex for controls |

## Maintenance Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| major_overhaul_interval_hours | int or None | None | Hours between major overhauls |
| major_overhaul_cost_per_kw | float or None | None | $/kW per major overhaul |
| minor_overhaul_interval_hours | int or None | None | Hours between minor overhauls |
| minor_overhaul_cost_per_kw | float or None | None | $/kW per minor overhaul |
| ltsa_cost_per_mwh | float or None | None | Long-term service agreement cost |

## Default Heat Rate Segments

```python
[
    HeatRateSegment(loading_fraction=0.5,  heat_rate_btu_per_kwh=9500),  # 50% load
    HeatRateSegment(loading_fraction=0.75, heat_rate_btu_per_kwh=8800),  # 75% load
    HeatRateSegment(loading_fraction=1.0,  heat_rate_btu_per_kwh=8500),  # full load
]
```

Lower heat rate = more efficient. Typical ranges by type:
- Reciprocating: 8,200-9,500 BTU/kWh
- Aero gas turbine: 9,000-11,000 BTU/kWh
- Industrial gas turbine: 9,500-11,500 BTU/kWh
- CCGT: 6,200-7,500 BTU/kWh
- Fuel cell: 6,500-8,500 BTU/kWh

## SP&L / DNM Field Mapping

These GasGenerator fields map directly to `small_chp.csv` in the Dynamic Network Model:

| GasGenerator Field | DNM small_chp Field |
|---|---|
| nameplate_mw | nameplate_mw |
| heat_rate_segments[1.0] | heat_rate_btu_per_kwh |
| forced_outage_rate | forced_outage_rate |
| planned_outage_rate | planned_outage_rate |
| min_stable_level_fraction | min_stable_level_fraction |
| startup_time_minutes | startup_time_minutes |
| gas_pressure_psig_required | gas_pressure_psig_required |
| ramp_rate_mw_per_min | ramp_rate_mw_per_min |
