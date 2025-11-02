╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — PRODUCTION & ECONOMY  ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"Steam powers the mill. The boiler feeds the press. Input becomes output. Metal becomes tools. The farm becomes an industry. Or it doesn't. Choice matters." — Industrialist's Manual*

---

## At a Glance

The production and economy system manages buildings, recipe queues, input/output conversion, pricing modifiers, and faction reputation effects. Players build structures, queue recipes, and convert raw materials into finished goods. Trade prices fluctuate with reputation.

---

## What It Simulates

- **Buildings**: Structures that process materials (boiler, mill, press)
- **Recipes**: Input → Output conversions with time requirements
- **Queues**: Production order management
- **Economy**: Settlement pricing, faction reputation modifiers
- **Bottlenecks**: Resource scarcity, queue limits

---

## Data It Owns

### Building State

```json
{
  "id": "boiler_001",
  "type": "steam_boiler",
  "position": {"x": 2, "y": 3},
  "recipe_queue": [
    {"recipe_id": "make_steam", "started_day": 45, "completion_day": 47}
  ],
  "is_active": true,
  "fuel_level": 50
}
```

### Recipe Data

```json
{
  "id": "make_steam",
  "name": "Generate Steam",
  "building_type": "steam_boiler",
  "input": {"fuel": 5, "water": 3},
  "output": {"steam_energy": 10},
  "time_days": 2,
  "description": "Boil water with fuel to create steam energy"
}
```

### Economy State

```json
{
  "settlement": "brassford",
  "base_prices": {
    "grain": 2,
    "steel_parts": 10,
    "fuel": 5
  },
  "price_modifiers": {
    "grain": 1.2,
    "steel_parts": 0.9
  },
  "faction_reputation": {
    "machinists": 20,
    "root_keepers": -10
  }
}
```

---

## Signals & Events

- `building_placed(building_id, position)` — Emitted when building placed
- `recipe_started(building_id, recipe_id)` — Emitted when recipe begins
- `recipe_completed(building_id, recipe_id, output)` — Emitted when recipe finishes
- `price_changed(item, old_price, new_price)` — Emitted when price updates
- `reputation_changed(faction, old_value, new_value)` — Emitted when reputation changes

---

## Player-Facing Effects

### Building Placement

**Action**: Select building from menu, place on grid

**Requirements**:
- Enough resources to build
- Valid position (not occupied)
- Adjacent to required structures (if any)

**Effect**: Building added to farm grid, resources consumed

### Recipe Queuing

**Action**: Select building, choose recipe, confirm

**Requirements**:
- Building has queue space
- Input resources available
- Recipe unlocked (if applicable)

**Effect**: Recipe added to queue, input resources reserved

### Production

**Automatic**: Each day advance, active recipes progress

**Completion**: When recipe completes:
- Output resources added to inventory
- Reserved input resources consumed
- Recipe removed from queue

### Trade

**Action**: Visit settlement, open trade menu

**Display**:
- Items available (sells/buys)
- Prices (base × reputation modifier)
- Player inventory
- Faction reputation

**Transaction**: Select items, confirm trade

---

## Recipe System

### Recipe Types

**Processing**: Input materials → Output materials (e.g., grain → flour)

**Crafting**: Multiple inputs → Single output (e.g., steel + bolts → tool)

**Generation**: Fuel/water → Energy (e.g., fuel + water → steam)

**Refinement**: Raw material → Refined material (e.g., metal_scrap → steel)

### Recipe Queue

**Capacity**: Each building has queue limit (default: 3 recipes)

**Order**: First in, first out (FIFO)

**Cancellation**: Player can cancel queued recipes (input refunded, output lost)

### Production Time

**Formula**: Recipe time_days × building efficiency (default: 1.0)

**Modifiers**:
- Building upgrades (+efficiency)
- Soil mood (if relevant)
- Entropy path (Order → machine efficiency, Wild → nature efficiency)

---

## Economy System

### Base Prices

**Settlement-Specific**: Each settlement has base prices for items

**Example**:
```json
{
  "brassford": {
    "grain": 2,
    "steel_parts": 10,
    "fuel": 5,
    "blueprints": 50
  }
}
```

### Reputation Modifiers

**Formula**: `final_price = base_price × (1 + reputation_modifier)`

**Modifier Calculation**:
- Reputation >20: -10% (friendly discount)
- Reputation -20 to +20: 0% (standard price)
- Reputation <-20: +20% (hostile markup)

**Example**:
- Base price: 10
- Reputation: 30 (friendly)
- Modifier: -10%
- Final price: 10 × 0.9 = 9

### Dynamic Pricing

**Events**: World events can change prices temporarily

**Example**: Settlement burns → prices spike (+50% for 30 days)

---

## Building Examples

### Steam Boiler

```json
{
  "id": "steam_boiler",
  "name": "Steam Boiler",
  "cost": {"steel_parts": 20, "bolts": 10},
  "recipes": ["make_steam", "power_machine"],
  "queue_limit": 3,
  "description": "Boils water to create steam energy"
}
```

### Mill

```json
{
  "id": "grain_mill",
  "name": "Grain Mill",
  "cost": {"wood": 30, "bolts": 5},
  "recipes": ["grind_grain", "make_flour"],
  "queue_limit": 2,
  "requires": {"steam_energy": 5},
  "description": "Grinds grain into flour"
}
```

### Press

```json
{
  "id": "oil_press",
  "name": "Oil Press",
  "cost": {"steel_parts": 15, "bolts": 8},
  "recipes": ["press_oil", "extract_essence"],
  "queue_limit": 2,
  "requires": {"steam_energy": 3},
  "description": "Presses seeds to extract oil"
}
```

---

## Recipe Examples

### Make Steam

```json
{
  "id": "make_steam",
  "name": "Generate Steam",
  "building_type": "steam_boiler",
  "input": {"fuel": 5, "water": 3},
  "output": {"steam_energy": 10},
  "time_days": 2
}
```

### Grind Grain

```json
{
  "id": "grind_grain",
  "name": "Grind Grain",
  "building_type": "grain_mill",
  "input": {"grain": 5, "steam_energy": 2},
  "output": {"flour": 4},
  "time_days": 1
}
```

### Press Oil

```json
{
  "id": "press_oil",
  "name": "Press Oil",
  "building_type": "oil_press",
  "input": {"seeds": 10, "steam_energy": 3},
  "output": {"oil": 3},
  "time_days": 2
}
```

---

## Balance Levers

- **Recipe Time**: Days per recipe (default: 1-3 days)
- **Queue Limits**: Capacity per building (default: 2-3)
- **Price Modifiers**: Reputation effects (±10% to ±20%)
- **Building Costs**: Resource requirements

**Safe Tweaks**:
- Adjust recipe time (±1 day)
- Modify queue limits (±1 slot)
- Tune price modifiers (±5%)

**Risky Tweaks**:
- Removing queue system (breaks production flow)
- Auto-completing recipes (removes player agency)

---

## Failure Modes

### Resource Scarcity

**Cause**: Not enough input resources for recipes

**Result**: Production stalls. Queue fills with incomplete recipes.

**Recovery**: Acquire resources through trade or harvest.

### Queue Overflow

**Cause**: Too many recipes queued, building can't keep up

**Result**: Player must wait or cancel recipes

**Recovery**: Cancel low-priority recipes, prioritize important ones.

### Price Inflation

**Cause**: Bad reputation or world events spike prices

**Result**: Trade becomes expensive, player can't afford items

**Recovery**: Improve reputation, wait for event to pass.

---

**Cross-References:**

- [Game Design](../GAME_DESIGN.md) • [Lore Bible](../LORE_BIBLE.md) • [Farming System](farming_system.md) • [Player Guide](../PLAYER_GUIDE/travel_and_trade.md) • [Technical](../TECHNICAL/architecture_overview.md)

