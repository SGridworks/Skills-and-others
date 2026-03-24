# DNM Data Expert - Tool Wrapper Skill

## Skill Identity

**Name**: dnm-data-expert  
**Purpose**: Provide on-demand context and querying conventions for the Dynamic Network Model (DNM) synthetic utility dataset  
**Trigger Keywords**: DNM, Dynamic Network Model, synthetic data, customer data, DER query, feeder, transformer, network topology  

## Tool Wrapper Pattern

This skill uses the Tool Wrapper pattern to inject DNM data context when triggered.

### Trigger Detection

Activate when user message contains:
- "DNM" or "Dynamic Network Model"
- "synthetic data" + utility/energy context
- "customer data" + network/grid context  
- "DER query", "DER data", "distributed energy resource"
- "feeder", "transformer", "network topology"
- "AMI data", "meter data", "consumption data"

### Context Loading

When triggered, automatically load:

1. **Schema Reference** → `references/schema.md`
   - Data dictionary for all tables
   - Field names, types, relationships
   - Primary/foreign key mappings

2. **Network Topology Reference** → `references/network-topology.md`
   - Graph structure documentation
   - Phase and voltage conventions
   - Parent-child relationships

### Response Format

When providing DNM context, structure responses as:

```
DNM Dataset Context

[Triggered by: <keyword>]

## Relevant Schema
<Pull from schema.md based on query context>

## Network Topology
<Pull from network-topology.md if relevant>

## Query Conventions
<Provide SQL/pandas patterns for common queries>

## Example Queries
<Show 2-3 relevant example queries>
```

## Query Conventions

### Standard Join Patterns

**Customer + DER lookup:**
```sql
SELECT c.customer_id, c.rate_class, d.der_type, d.capacity_kw
FROM customers c
LEFT JOIN ders d ON c.customer_id = d.customer_id
WHERE c.customer_id = '<id>';
```

**AMI consumption for a customer:**
```sql
SELECT a.timestamp, a.kwh
FROM ami_data a
JOIN meters m ON a.meter_id = m.meter_id
WHERE m.customer_id = '<id>'
  AND a.timestamp BETWEEN '<start>' AND '<end>'
ORDER BY a.timestamp;
```

**Feeder topology traversal:**
```sql
-- Get all equipment downstream of a feeder
WITH RECURSIVE downstream AS (
    SELECT node_id, parent_node_id, equipment_type
    FROM network_nodes
    WHERE node_id = '<feeder_id>'
    UNION ALL
    SELECT n.node_id, n.parent_node_id, n.equipment_type
    FROM network_nodes n
    JOIN downstream d ON n.parent_node_id = d.node_id
)
SELECT * FROM downstream;
```

### Common Filter Patterns

- **Date ranges**: Use ISO format 'YYYY-MM-DD HH:MM:SS'
- **Rate classes**: Typically residential, commercial, industrial
- **DER types**: 'solar_pv', 'battery_storage', 'ev_charger'
- **Phases**: 'A', 'B', 'C', 'AB', 'BC', 'CA', 'ABC'
- **Voltages**: 'primary' (typically 12-35kV), 'secondary' (120-480V)

### Aggregation Conventions

- **Hourly**: Raw AMI data is hourly
- **Daily**: SUM(kwh) for consumption
- **Monthly**: Aggregated by billing cycle
- **Peak demand**: MAX(kwh) per day/month

## Usage Examples

**User**: "How do I query all solar DERs on feeder F001?"

**Response**:
```
DNM Dataset Context

[Triggered by: feeder + DER query]

## Relevant Schema
- customers: customer_id, feeder_id, transformer_id
- ders: der_id, customer_id, der_type, capacity_kw, install_date

## Query Pattern
```sql
SELECT d.der_id, d.der_type, d.capacity_kw, 
       c.customer_id, c.rate_class
FROM ders d
JOIN customers c ON d.customer_id = c.customer_id
WHERE d.der_type = 'solar_pv'
  AND c.feeder_id = 'F001';
```

## Expected Output Format
| der_id | der_type | capacity_kw | customer_id | rate_class |
|--------|----------|-------------|-------------|------------|
| DER001 | solar_pv | 8.5 | C12345 | residential |
```

## Python/Pandas Patterns

The DNM has dedicated load functions. Always prefer these over raw pd.read_csv:

```python
import sys; sys.path.insert(0, '/Users/2agents/Projects/Dynamic-Network-Model')
from demo_data.load_demo_data import (
    load_feeders, load_customers, load_der_customers,
    load_hosting_capacity, load_load_profiles, load_all
)

# DER capacity by feeder
der = load_der_customers()
der.groupby('feeder_id')['capacity_kw'].sum().sort_values(ascending=False)

# Customer count by rate class per feeder
cust = load_customers()
cust.groupby(['feeder_id', 'rate_class']).size().unstack(fill_value=0)

# Load profiles -- FILTER FIRST (1.4M rows)
import pandas as pd
lp = pd.read_csv(
    '/Users/2agents/Projects/Dynamic-Network-Model/demo_data/load_profiles.csv.gz',
    usecols=['feeder_id','hour','load_kw']
)
lp = lp[lp['feeder_id'] == 'F001']  # filter before analysis
```

Use `/Users/2agents/btm-optimize/.venv/bin/python3` for pandas/numpy.

## Join Key Hierarchy

`substation_id -> feeder_id -> transformer_id -> customer_id`

Every table carries feeder_id and substation_id. Community solar and microgrids join on feeder_id (not customer_id). CHP and BESS join on customer_id.

## Files

- `SKILL.md` - This file (Tool Wrapper pattern)
- `references/schema.md` - Complete data dictionary
- `references/network-topology.md` - Network graph documentation
