# DNM Network Topology Reference

Graph structure and electrical conventions for the Dynamic Network Model.

---

## Graph Structure Overview

The DNM uses a hierarchical directed graph to represent the electrical distribution network.

### Node Types

| Equipment Type | Description | Typical Count |
|----------------|-------------|---------------|
| substation | Bulk power entry point | 10-20 per model |
| feeder | Primary distribution circuit | 50-100 per model |
| switch | Sectionalizing switch | 200-500 per model |
| recloser | Protection device | 100-200 per model |
| transformer | Voltage step-down | 10,000-20,000 per model |
| meter | Customer meter point | 140,000 per model |
| load | Aggregated load point | Varies |

### Graph Properties

- **Directed**: Power flows from substation → feeder → transformer → meter
- **Acyclic**: No loops in the normal configuration
- **Tree-like**: Primarily radial structure with possible ties (normally open)
- **Hierarchical**: Clear parent-child relationships

---

## Network Hierarchy

```
Substation (S001)
    └── Feeder (F001) - 12.47kV Primary
            ├── Switch (SW001)
            ├── Recloser (R001)
            ├── Transformer (T001234) - 75kVA
            │       ├── Meter (M987654321) - Customer C123456789
            │       └── Meter (M987654322) - Customer C123456790
            ├── Transformer (T001235) - 100kVA
            │       ├── Meter (M987654323) - Commercial customer
            │       └── ...
            └── Transformer (T001236)
                    └── ...
```

### Depth Levels

| Depth | Level | Typical Equipment |
|-------|-------|-------------------|
| 0 | Substation | Bulk power transformers |
| 1 | Feeder head | Circuit breakers, primary |
| 2 | Primary mains | Switches, reclosers, taps |
| 3 | Distribution transformers | Step-down to secondary |
| 4 | Service points | Meters, customer service |

---

## Phase Conventions

### Single Phase Designations

| Code | Description | Typical Use |
|------|-------------|-------------|
| A | Phase A only | Single-phase residential |
| B | Phase B only | Single-phase residential |
| C | Phase C only | Single-phase residential |

### Two-Phase Designations

| Code | Description | Typical Use |
|------|-------------|-------------|
| AB | Phases A and B | Small commercial, 208V |
| BC | Phases B and C | Small commercial, 208V |
| CA | Phases C and A | Small commercial, 208V |

### Three-Phase Designations

| Code | Description | Typical Use |
|------|-------------|-------------|
| ABC | All three phases | Commercial, industrial, large residential |

### Phase Assignment Rules

1. **Residential**: Typically single-phase (A, B, or C), balanced across feeder
2. **Commercial**: Two-phase (AB, BC, CA) or three-phase (ABC)
3. **Industrial**: Always three-phase (ABC)
4. **Transformers**: Phase matches connected primary phase(s)
5. **Primary mains**: May be single or three-phase

### Phase Balancing

Feeders aim for balanced loading across phases:
```
Target balance: ±10% difference in connected kVA per phase
Typical residential: Rotated A-B-C-A-B-C along feeder
Commercial: Assigned based on load requirements
```

---

## Voltage Levels

### Primary Distribution

| Voltage | Description | Application |
|---------|-------------|-------------|
| 12.47kV | Common US standard | Urban, suburban distribution |
| 13.8kV | Higher capacity | Dense urban, commercial areas |
| 24.9kV | Long rural feeders | Rural, low-density areas |
| 34.5kV | Sub-transmission | Large systems, industrial |

### Secondary Distribution

| Voltage | Configuration | Application |
|---------|---------------|-------------|
| 120/240V | Split-phase | Standard residential |
| 208Y/120V | Three-phase wye | Commercial, small industrial |
| 480Y/277V | Three-phase wye | Commercial, industrial |
| 480V Delta | Three-phase delta | Industrial motors |

### Voltage Classification

| Level | Range | network_nodes.voltage_level |
|-------|-------|----------------------------|
| Primary | > 1kV | 'primary' |
| Secondary | ≤ 1kV | 'secondary' |

---

## Parent-Child Relationships

### Hierarchical Structure

```sql
-- Each node has exactly one parent (except substations)
-- Each node can have multiple children

Substation (no parent)
    ↓
Feeder (parent = substation)
    ↓
Primary equipment (parent = feeder or other primary)
    ↓
Transformer (parent = primary equipment)
    ↓
Meter/Load (parent = transformer)
```

### Traversal Patterns

**Get all descendants of a node:**
```sql
WITH RECURSIVE descendants AS (
    SELECT node_id, parent_node_id, equipment_type, 0 as depth
    FROM network_nodes
    WHERE node_id = '<start_node>'
    
    UNION ALL
    
    SELECT n.node_id, n.parent_node_id, n.equipment_type, d.depth + 1
    FROM network_nodes n
    JOIN descendants d ON n.parent_node_id = d.node_id
)
SELECT * FROM descendants ORDER BY depth;
```

**Get all ancestors of a node:**
```sql
WITH RECURSIVE ancestors AS (
    SELECT node_id, parent_node_id, equipment_type, 0 as depth
    FROM network_nodes
    WHERE node_id = '<start_node>'
    
    UNION ALL
    
    SELECT n.node_id, n.parent_node_id, n.equipment_type, a.depth + 1
    FROM network_nodes n
    JOIN ancestors a ON n.node_id = a.parent_node_id
)
SELECT * FROM ancestors ORDER BY depth;
```

---

## Network Edges

### Edge Types

| Type | Description | Impedance Characteristics |
|------|-------------|---------------------------|
| overhead | Aerial conductors | Higher reactance, lower capacitance |
| underground | Buried cables | Lower reactance, higher capacitance |
| switch | Switchable connection | Negligible impedance when closed |
| regulator | Voltage regulator | Adds impedance, controls voltage |

### Impedance Values

Typical per-mile values for 12.47kV primary:

| Conductor | R (ohms/mi) | X (ohms/mi) | Ampacity (A) |
|-----------|-------------|-------------|--------------|
| AAC 1/0 | 0.97 | 0.42 | 275 |
| AAC 4/0 | 0.49 | 0.40 | 375 |
| ACSR 1/0 | 1.12 | 0.43 | 275 |
| ACSR 4/0 | 0.59 | 0.41 | 375 |

---

## Radial vs. Network Topology

### Normal Configuration (Radial)

```
Substation → Feeder → Transformers → Customers
    (One path from source to each load)
```

- Simple protection coordination
- Clear fault isolation
- Higher reliability concerns

### Tie Switch Configuration

```
Feeder A ──┬── Section 1 ──┬── Section 2 ──┐
           │               │               │
          Switch          Switch        Tie Switch (normally open)
           │               │               │
Feeder B ──┴── Section 3 ──┴── Section 4 ──┘
```

- Tie switches provide backup paths
- Normally open during regular operation
- Closed during contingencies for load transfer

### Loop/Switching Configuration

```
         Switch (normally closed)
              │
Substation ───┼── Primary Main ──┬── Transformer
              │                  │
              └─ Backup Path ────┘
                   (normally open)
```

---

## Common Topology Queries

### Find all customers downstream of a switch

```sql
WITH RECURSIVE downstream AS (
    SELECT node_id, parent_node_id, equipment_type
    FROM network_nodes
    WHERE node_id = '<switch_node_id>'
    
    UNION ALL
    
    SELECT n.node_id, n.parent_node_id, n.equipment_type
    FROM network_nodes n
    JOIN downstream d ON n.parent_node_id = d.node_id
)
SELECT c.*
FROM customers c
JOIN meters m ON c.meter_id = m.meter_id
JOIN network_nodes nn ON m.meter_id = nn.equipment_id
JOIN downstream d ON nn.node_id = d.node_id
WHERE nn.equipment_type = 'meter';
```

### Calculate electrical distance from substation

```sql
WITH RECURSIVE distance AS (
    SELECT 
        node_id, 
        parent_node_id, 
        0 as hop_count,
        0.0 as total_impedance_r,
        0.0 as total_impedance_x
    FROM network_nodes
    WHERE equipment_type = 'substation'
    
    UNION ALL
    
    SELECT 
        n.node_id,
        n.parent_node_id,
        d.hop_count + 1,
        d.total_impedance_r + COALESCE(e.impedance_r, 0),
        d.total_impedance_x + COALESCE(e.impedance_x, 0)
    FROM network_nodes n
    JOIN distance d ON n.parent_node_id = d.node_id
    LEFT JOIN network_edges e ON e.to_node_id = n.node_id
)
SELECT * FROM distance;
```

### Identify phase imbalance on a feeder

```sql
SELECT 
    c.phase,
    COUNT(*) as customer_count,
    SUM(c.annual_kwh) as total_kwh,
    AVG(c.peak_kw) as avg_peak_kw
FROM customers c
WHERE c.feeder_id = 'F001'
GROUP BY c.phase
ORDER BY c.phase;
```

---

## GIS Integration

### Coordinate System

- **Latitude/Longitude**: WGS84 (EPSG:4326)
- **Precision**: 8 decimal places (~1mm accuracy)
- **Coverage**: Synthetic service territory

### Spatial Queries

**Find transformers within radius:**
```sql
SELECT * FROM transformers
WHERE SQRT(POWER(latitude - <center_lat>, 2) + 
           POWER(longitude - <center_lon>, 2)) * 111000 <= <radius_meters>;
```

**Line segment distance calculation:**
```sql
SELECT 
    edge_id,
    111000 * SQRT(
        POWER(n2.latitude - n1.latitude, 2) + 
        POWER(n2.longitude - n1.longitude, 2)
    ) as calculated_length_meters
FROM network_edges e
JOIN network_nodes n1 ON e.from_node_id = n1.node_id
JOIN network_nodes n2 ON e.to_node_id = n2.node_id;
```

---

## Protection and Switching

### Device Hierarchy

1. **Substation Breaker**: Highest level protection
2. **Reclosers**: Mid-feeder fault interruption
3. **Sectionalizing Switches**: Manual isolation points
4. **Fuses**: Transformer/branch protection

### Protection Zones

```
Zone 1: Substation breaker → First recloser
Zone 2: Recloser → Next protective device
Zone 3: Transformer fuse → Customer service
```

### Coordination Principles

- **Time-Current Curves**: Devices closer to substation have slower curves
- **Reach**: Each device protects its downstream zone
- **Backup**: Upstream device provides backup protection
