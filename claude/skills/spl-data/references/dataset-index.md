# SP&L Dataset Index

## Which dataset answers which question?

| Question | Primary Dataset | Join With |
|----------|----------------|-----------|
| Where are the substations? | substations | -- |
| What feeders serve an area? | feeders | substations |
| What's the transformer loading? | transformers | customers (aggregate demand) |
| How many customers per feeder? | customers | feeders |
| What's the peak load? | load_profiles | feeders |
| What does a customer's usage look like? | customer_interval_data | customers |
| Where is solar installed? | solar_installations | customers, transformers |
| How much EV load? | ev_chargers | customers |
| How much storage? | battery_installations | customers |
| What's the weather correlation? | weather_data | load_profiles (by timestamp) |
| What could go wrong? | outage_history | feeders, weather_data |
| What's the network topology? | network_nodes + network_edges | feeders |
| How much DER can a transformer take? | hosting_capacity | transformers |
| Where is community solar? | community_solar | feeders |
| Where are EV depots? | ev_charging_depots | feeders, transformers |
| Can this site island? | microgrids | feeders |
| Where is CHP running? | small_chp | customers, transformers |
| Where is commercial storage? | commercial_bess | customers, transformers |
| What's in the interconnection queue? | interconnection_queue | feeders |
| What does the future look like? | growth_scenarios | -- (projections) |
| What's the solar generation curve? | solar_profiles | -- (typical shapes) |
| What's the EV charging pattern? | ev_charging_profiles | -- (typical shapes) |

## Join Key Hierarchy

```
substations (23)
  |-- substation_id
  +-- feeders (104)
        |-- feeder_id
        +-- transformers (36,668)
              |-- transformer_id
              +-- customers (237,713)
                    |-- customer_id
                    +-- solar_installations (28,660)
                    +-- ev_chargers (19,015)
                    +-- battery_installations (7,055)
                    +-- small_chp (23)
                    +-- commercial_bess (31)
```

**Feeder-level assets** (no customer_id):
- community_solar (42) -- joins on feeder_id
- ev_charging_depots (13) -- joins on feeder_id + transformer_id
- microgrids (10) -- joins on feeder_id
- interconnection_queue (83) -- joins on feeder_id

**Per-transformer**:
- hosting_capacity (36,668) -- joins on transformer_id

**Standalone** (no spatial join):
- growth_scenarios, solar_profiles, ev_charging_profiles, weather_data
