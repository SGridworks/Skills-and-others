# SolarArray Field Reference

Source: `btm-optimize/src/btm_optimize/models/equipment.py`
Class: `SolarArray(BaseModel)` -- frozen

## Fields

| Field | Type | Default | Constraint | Units | Description |
|-------|------|---------|------------|-------|-------------|
| name | str | required | -- | -- | Human-readable identifier |
| capacity_mw_dc | float | required | gt=0 | MW-DC | DC nameplate capacity |
| inverter_capacity_mw_ac | float or None | None | -- | MW-AC | AC inverter rating; None = same as DC |
| tilt_deg | float or None | None | -- | degrees | Panel tilt; None = latitude-optimal |
| azimuth_deg | float | 180.0 | -- | degrees | Panel azimuth (180 = due south) |
| annual_degradation_rate | float | 0.005 | [0, 0.05] | fraction/yr | Annual capacity degradation (0.5%/yr) |
| capex_per_kw_dc | float | 1100.0 | ge=0 | $/kW-DC | Installed capital cost |
| fixed_om_per_kw_yr | float | 12.0 | ge=0 | $/kW-yr | Annual fixed O&M |
| economic_life_years | int | 30 | ge=1 | years | Project economic life |

## Computed Properties

- `dc_ac_ratio` = `capacity_mw_dc / inverter_capacity_mw_ac` (1.0 if inverter is None)

## Phoenix-Specific Defaults

For SP&L / Phoenix, AZ:
- Latitude: ~33.45 N
- Optimal tilt: 20-30 degrees (lower than latitude for summer peak)
- Azimuth: 170-200 degrees (south-facing, slight west bias for afternoon peak)
- Typical DC/AC ratio: 1.2-1.4 (oversize DC for better economics)
- Degradation: 0.004-0.006 (desert = slightly higher than average)

## SP&L / DNM Field Mapping

These SolarArray fields map to `community_solar.csv` in the Dynamic Network Model:

| SolarArray Field | DNM community_solar Field |
|---|---|
| capacity_mw_dc | nameplate_dc_mw |
| inverter_capacity_mw_ac | nameplate_ac_mw |
| dc_ac_ratio | dc_ac_ratio |
| annual_degradation_rate | annual_degradation_rate |
| tilt_deg | tilt_degrees |
| azimuth_deg | azimuth_degrees |

Note: DNM uses `_degrees` suffix while BTM uses `_deg`. Same semantics.
