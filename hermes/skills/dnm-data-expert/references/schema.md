# DNM Data Schema Reference

Complete data dictionary for the Dynamic Network Model synthetic utility dataset.

## Dataset Overview

- **Customers**: 140,000 synthetic PII-free customer records
- **DERs**: 43,000 Distributed Energy Resources
- **AMI Data**: Hourly consumption readings
- **Network**: Full feeder/transformer topology

---

## customers

Primary customer account table.

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| customer_id | VARCHAR(20) | Unique customer identifier | C123456789 |
| rate_class | VARCHAR(20) | Billing rate classification | residential, commercial, industrial |
| annual_kwh | DECIMAL(10,2) | Annual energy consumption | 8542.50 |
| peak_kw | DECIMAL(8,2) | Peak demand (kW) | 12.5 |
| feeder_id | VARCHAR(20) | Parent feeder identifier | F001 |
| transformer_id | VARCHAR(20) | Service transformer ID | T001234 |
| service_address | VARCHAR(100) | Synthetic address | 123 Main St |
| latitude | DECIMAL(10,8) | Geographic latitude | 40.71280000 |
| longitude | DECIMAL(11,8) | Geographic longitude | -74.00600000 |
| service_voltage | VARCHAR(10) | Service voltage level | 120/240, 277/480 |
| phase | VARCHAR(5) | Service phase connection | A, B, C, AB, BC, CA, ABC |
| meter_id | VARCHAR(20) | AMI meter identifier | M987654321 |
| account_status | VARCHAR(10) | Account status | active, inactive |
| enrollment_date | DATE | Service start date | 2015-03-15 |

**Primary Key**: customer_id  
**Foreign Keys**: feeder_id → feeders, transformer_id → transformers, meter_id → meters

---

## ders

Distributed Energy Resources (solar, battery, EV chargers).

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| der_id | VARCHAR(20) | Unique DER identifier | DER00012345 |
| customer_id | VARCHAR(20) | Owning customer | C123456789 |
| der_type | VARCHAR(25) | Type of DER | solar_pv, battery_storage, ev_charger |
| capacity_kw | DECIMAL(8,2) | Nameplate capacity | 10.0 |
| capacity_kwh | DECIMAL(8,2) | Energy capacity (batteries) | 13.5 |
| install_date | DATE | Installation date | 2020-06-15 |
| status | VARCHAR(10) | Operational status | active, inactive, pending |
| inverter_efficiency | DECIMAL(4,3) | Inverter efficiency | 0.970 |
| tilt_angle | DECIMAL(5,2) | Panel tilt (solar) | 30.00 |
| azimuth | DECIMAL(5,2) | Panel orientation (solar) | 180.00 |
| battery_cycles | INTEGER | Cycle count (batteries) | 1250 |
| ev_connector | VARCHAR(10) | Connector type (EV) | Level2, DC_fast |
| control_enabled | BOOLEAN | Remote control capable | true, false |
| telemetry_source | VARCHAR(20) | Data source | inverter_api, scada, estimated |

**Primary Key**: der_id  
**Foreign Key**: customer_id → customers

### DER Type Distribution
- **solar_pv**: ~70% of DERs
- **battery_storage**: ~20% of DERs
- **ev_charger**: ~10% of DERs

---

## ami_data

Advanced Metering Infrastructure - hourly consumption data.

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| meter_id | VARCHAR(20) | Meter identifier | M987654321 |
| timestamp | DATETIME | Reading timestamp | 2023-06-15 14:00:00 |
| kwh | DECIMAL(10,4) | Hourly consumption (kWh) | 2.4567 |
| kw | DECIMAL(10,4) | Average demand (kW) | 2.4567 |
| voltage_a | DECIMAL(6,2) | Phase A voltage | 120.5 |
| voltage_b | DECIMAL(6,2) | Phase B voltage | 121.2 |
| voltage_c | DECIMAL(6,2) | Phase C voltage | 120.8 |
| current_a | DECIMAL(6,3) | Phase A current | 15.250 |
| current_b | DECIMAL(6,3) | Phase B current | 12.100 |
| current_c | DECIMAL(6,3) | Phase C current | 0.000 |
| power_factor | DECIMAL(4,3) | Power factor | 0.950 |
| reading_quality | VARCHAR(10) | Data quality flag | valid, estimated, missing |
| temperature | DECIMAL(5,2) | Local temperature (°F) | 78.50 |

**Primary Key**: (meter_id, timestamp)  
**Foreign Key**: meter_id → meters

### Data Characteristics
- **Granularity**: Hourly readings
- **Date Range**: Typically 2+ years of history
- **Coverage**: 100% of active customers
- **Quality**: ~95% valid reads, ~4% estimated, ~1% missing

---

## meters

Meter registry linking to customers and network locations.

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| meter_id | VARCHAR(20) | Unique meter identifier | M987654321 |
| customer_id | VARCHAR(20) | Associated customer | C123456789 |
| meter_type | VARCHAR(20) | Meter model/type | AMI-smart, polyphase |
| install_date | DATE | Installation date | 2018-01-15 |
| comm_module | VARCHAR(20) | Communication type | cellular, mesh, fiber |
| last_comm | DATETIME | Last communication | 2023-06-15 14:15:00 |
| comm_status | VARCHAR(10) | Communication health | online, offline, intermittent |
| firmware_version | VARCHAR(15) | Meter firmware | v2.4.1 |

**Primary Key**: meter_id  
**Foreign Key**: customer_id → customers

---

## feeders

Primary distribution feeders.

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| feeder_id | VARCHAR(20) | Unique feeder identifier | F001 |
| substation_id | VARCHAR(20) | Parent substation | S001 |
| feeder_name | VARCHAR(50) | Descriptive name | Main St Feeder 1 |
| voltage_kv | DECIMAL(5,2) | Nominal voltage (kV) | 12.47 |
| capacity_mva | DECIMAL(6,2) | Thermal capacity | 10.00 |
| length_miles | DECIMAL(6,2) | Total line length | 15.50 |
| customer_count | INTEGER | Connected customers | 5234 |
| der_count | INTEGER | Connected DERs | 450 |
| peak_load_kw | DECIMAL(10,2) | Historical peak | 8500.00 |
| install_date | DATE | Construction date | 1985-06-01 |
| status | VARCHAR(10) | Operational status | active, planned, retired |

**Primary Key**: feeder_id  
**Foreign Key**: substation_id → substations

---

## transformers

Distribution transformers.

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| transformer_id | VARCHAR(20) | Unique transformer ID | T001234 |
| feeder_id | VARCHAR(20) | Parent feeder | F001 |
| transformer_type | VARCHAR(20) | Equipment type | pole_mount, pad_mount, vault |
| capacity_kva | DECIMAL(8,2) | Nameplate capacity | 75.00 |
| primary_voltage | DECIMAL(6,2) | Primary voltage (V) | 12470.00 |
| secondary_voltage | VARCHAR(15) | Secondary voltage | 120/240, 277/480 |
| phase | VARCHAR(5) | Phase configuration | A, B, C, AB, BC, CA, ABC |
| customer_count | INTEGER | Connected customers | 8 |
| install_date | DATE | Installation date | 2010-03-15 |
| last_inspection | DATE | Last inspection | 2023-01-10 |
| health_score | DECIMAL(4,2) | Condition score (0-1) | 0.85 |
| xfmr_latitude | DECIMAL(10,8) | Location latitude | 40.71280000 |
| xfmr_longitude | DECIMAL(11,8) | Location longitude | -74.00600000 |

**Primary Key**: transformer_id  
**Foreign Keys**: feeder_id → feeders

### Typical Capacities
- Residential: 25-75 kVA
- Commercial: 100-500 kVA
- Industrial: 500+ kVA

---

## network_nodes

Graph nodes representing electrical equipment.

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| node_id | VARCHAR(20) | Unique node identifier | N001234 |
| parent_node_id | VARCHAR(20) | Parent in hierarchy | N001200 |
| equipment_type | VARCHAR(20) | Type of equipment | feeder, transformer, meter, switch, recloser |
| equipment_id | VARCHAR(20) | Reference to equipment table | T001234 |
| phase | VARCHAR(5) | Phases present | A, B, C, AB, BC, CA, ABC |
| voltage_level | VARCHAR(10) | Voltage classification | primary, secondary |
| latitude | DECIMAL(10,8) | Geographic latitude | 40.71280000 |
| longitude | DECIMAL(11,8) | Geographic longitude | -74.00600000 |
| depth | INTEGER | Hierarchy depth from substation | 3 |

**Primary Key**: node_id  
**Foreign Key**: parent_node_id → network_nodes (self-referential)

---

## network_edges

Graph edges representing electrical connections.

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| edge_id | VARCHAR(20) | Unique edge identifier | E001234 |
| from_node_id | VARCHAR(20) | Source node | N001200 |
| to_node_id | VARCHAR(20) | Destination node | N001234 |
| conductor_type | VARCHAR(20) | Wire/cable type | AAC_1/0, ACSR_4/0, URD_cable |
| length_feet | DECIMAL(8,2) | Segment length | 250.00 |
| phase | VARCHAR(5) | Phases carried | A, B, C, AB, BC, CA, ABC |
| ampacity | DECIMAL(6,2) | Current rating (A) | 315.00 |
| impedance_r | DECIMAL(8,6) | Resistance (ohms) | 0.025400 |
| impedance_x | DECIMAL(8,6) | Reactance (ohms) | 0.008200 |
| switch_status | VARCHAR(10) | Switch state | closed, open |

**Primary Key**: edge_id  
**Foreign Keys**: from_node_id → network_nodes, to_node_id → network_nodes

---

## substations

Bulk power substations.

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| substation_id | VARCHAR(20) | Unique substation ID | S001 |
| substation_name | VARCHAR(50) | Descriptive name | Main St Substation |
| voltage_high_kv | DECIMAL(6,2) | Transmission voltage | 69.00 |
| voltage_low_kv | DECIMAL(5,2) | Distribution voltage | 12.47 |
| capacity_mva | DECIMAL(6,2) | Total capacity | 50.00 |
| feeder_count | INTEGER | Number of feeders | 8 |
| latitude | DECIMAL(10,8) | Geographic latitude | 40.71280000 |
| longitude | DECIMAL(11,8) | Geographic longitude | -74.00600000 |

**Primary Key**: substation_id

---

## Key Relationships

```
substations
    ↓ (1:N)
feeders
    ↓ (1:N)
transformers ← network_nodes (equipment_id)
    ↓ (1:N)
customers ← meters (customer_id)
    ↓ (1:N)
ders

network_nodes (parent-child hierarchy)
    ↓ (1:N)
network_edges (from_node → to_node)

meters → ami_data (meter_id)
```

## Common Join Paths

**Full customer → DER → meter → AMI chain:**
```sql
SELECT c.*, d.*, m.*, a.*
FROM customers c
LEFT JOIN ders d ON c.customer_id = d.customer_id
JOIN meters m ON c.meter_id = m.meter_id
JOIN ami_data a ON m.meter_id = a.meter_id
WHERE c.customer_id = '<id>';
```

**Feeder topology with customers:**
```sql
SELECT f.*, t.*, c.customer_id, c.rate_class
FROM feeders f
JOIN transformers t ON f.feeder_id = t.feeder_id
JOIN customers c ON t.transformer_id = c.transformer_id
WHERE f.feeder_id = 'F001';
```
