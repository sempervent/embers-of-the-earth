╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — OVERWORLD & TRAVEL    ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"The road is dangerous. Bandits wear gear-masks. Machine-beasts stalk the wasteland. But the settlements await. Trade. Rumors. Marriages. Your legacy spreads with every journey."* — Traveler's Codex

---

## At a Glance

The overworld and travel system manages regions, settlements, encounters, hazards, and choice-based resolution. Players plan routes, encounter events, make choices, and pay resource costs. Time and supplies matter.

---

## What It Simulates

- **Regions**: Different terrain types (ashlands, rust plains, fungal groves)
- **Settlements**: Trading posts, faction strongholds, hidden groves
- **Encounters**: Random events (bandits, merchants, machine-beasts)
- **Hazards**: Choice-based challenges (weather, breakdowns, ambushes)
- **Travel Costs**: Days, food, fuel consumed per journey

---

## Data It Owns

### Region Data

```json
{
  "id": "ashlands",
  "name": "Ashlands",
  "terrain_type": "wasteland",
  "travel_cost_days": 3,
  "travel_cost_food": 5,
  "travel_cost_fuel": 2,
  "hazard_rate": 0.3,
  "description": "Barren wasteland covered in ash"
}
```

### Settlement Data

```json
{
  "id": "brassford",
  "name": "Brassford",
  "faction": "machinists",
  "region": "ashlands",
  "distance_days": 5,
  "economy": {
    "sells": ["steel_parts", "blueprints", "mechanical_tools"],
    "buys": ["ironwheat", "metal_scrap", "fuel"],
    "price_modifier": 1.0
  },
  "marriage_rules": {
    "allows": ["machinists", "rusted_brotherhood"],
    "requires": ["ironwheat_tribute", "apprenticeship"]
  }
}
```

### Encounter Data

```json
{
  "id": "bandits_masked",
  "name": "Gear-Masked Bandits",
  "weight": 4,
  "requires": {"vigor_min": 3},
  "choices": [
    {
      "id": "pay_tribute",
      "text": "Pay tribute (10 grain)",
      "effects": {
        "lose": {"grain": 10},
        "rumor": "tribute_paid"
      }
    },
    {
      "id": "flee",
      "text": "Attempt to flee",
      "tests": {"resolve": 5},
      "success": {"days_lost": 1},
      "fail": {"injury": "cut", "days_lost": 2}
    }
  ]
}
```

---

## Signals & Events

- `travel_started(from, to, days)` — Emitted when travel begins
- `travel_completed(to, days_consumed)` — Emitted when travel finishes
- `encounter_triggered(encounter_id)` — Emitted when encounter occurs
- `hazard_choice_made(choice_id, result)` — Emitted when hazard choice resolved
- `settlement_reached(settlement_id)` — Emitted when settlement reached

---

## Player-Facing Effects

### Route Planning

**Action**: Open map, select destination settlement

**Display**:
- Distance (days)
- Food cost
- Fuel cost
- Hazard probability
- Settlement info (faction, economy, marriage rules)

**Decision**: Confirm travel or cancel

### Travel Process

**Time**: Each travel day advances game clock

**Resources**: Food and fuel consumed per day

**Encounters**: 30% chance per day for random encounter

**Hazards**: Weather events, breakdowns, ambushes

### Encounters

**Trigger**: Random roll during travel (30% chance per day)

**Types**:
- **Bandits** — Gear-masked scavengers demanding tribute
- **Merchants** — Wandering traders offering goods
- **Machine-Beasts** — Twisted mechanical creatures
- **Refugees** — Survivors seeking help
- **Faction Patrol** — Friendly or hostile depending on reputation

**Resolution**: Choice-based (pay, flee, fight, negotiate)

### Hazards

**Types**:
- **Weather** — Ashfall, storms, heat waves
- **Breakdowns** — Vehicle/equipment failures
- **Ambushes** — Surprise attacks
- **Injuries** — Cuts, bruises, exhaustion

**Resolution**: Player makes choice, system tests stats, outcome determined

---

## Choice Resolution

### Stat Tests

**Format**: `{"stat_name": threshold}`

**Example**: `{"resolve": 5}` tests if player's Resolve stat >= 5

**Result**:
- **Success**: Positive outcome (avoid injury, save resources)
- **Failure**: Negative outcome (injury, resource loss, time lost)

### Effects

**Resource Loss**: `{"lose": {"grain": 10, "fuel": 5}}`

**Resource Gain**: `{"gain": {"steel_parts": 2}}`

**Time Loss**: `{"days_lost": 2}`

**Injuries**: `{"injury": "cut"}` (adds injury to player state)

**Rumors**: `{"rumor": "tribute_paid"}` (generates rumor)

---

## Encounter Examples

### Bandits (Gear-Masked)

```json
{
  "id": "bandits_masked",
  "weight": 4,
  "requires": {"vigor_min": 3},
  "choices": [
    {
      "id": "pay_tribute",
      "text": "Pay tribute (10 grain)",
      "effects": {"lose": {"grain": 10}, "rumor": "tribute_paid"}
    },
    {
      "id": "flee",
      "text": "Attempt to flee",
      "tests": {"resolve": 5},
      "success": {"days_lost": 1},
      "fail": {"injury": "cut", "days_lost": 2}
    },
    {
      "id": "negotiate",
      "text": "Negotiate (Diplomacy 10+)",
      "tests": {"diplomacy": 10},
      "success": {"lose": {"grain": 5}},
      "fail": {"lose": {"grain": 15}, "injury": "bruise"}
    }
  ]
}
```

### Wandering Merchant

```json
{
  "id": "merchant_wandering",
  "weight": 2,
  "choices": [
    {
      "id": "trade",
      "text": "Trade with merchant",
      "effects": {"open_trade_menu": true}
    },
    {
      "id": "ignore",
      "text": "Continue journey",
      "effects": {}
    }
  ]
}
```

### Machine-Beast Attack

```json
{
  "id": "machine_beast",
  "weight": 3,
  "requires": {"order_entropy_min": 20},
  "choices": [
    {
      "id": "flee",
      "text": "Run away (Vigor 8+)",
      "tests": {"vigor": 8},
      "success": {"days_lost": 1},
      "fail": {"injury": "serious_cut", "days_lost": 3}
    },
    {
      "id": "fight",
      "text": "Fight the beast (Resolve 12+)",
      "tests": {"resolve": 12},
      "success": {"gain": {"mechanical_parts": 5}},
      "fail": {"injury": "serious_cut", "days_lost": 2}
    }
  ]
}
```

---

## Balance Levers

- **Encounter Rate**: Chance per day (default: 30%)
- **Hazard Rate**: Per-region chance (default: 30%)
- **Travel Costs**: Days, food, fuel per region
- **Stat Test Thresholds**: Difficulty of choice outcomes

**Safe Tweaks**:
- Adjust encounter rate (±10%)
- Modify travel costs (±1 day, ±1 resource)
- Tune stat test thresholds (±2 points)

**Risky Tweaks**:
- Removing encounter system (removes core mechanic)
- Auto-resolving all choices (reduces player agency)

---

## Failure Modes

### Out of Supplies

**Cause**: No food or fuel during travel

**Result**: Travel stops. Player must find supplies or return.

**Recovery**: Find settlement or return home.

### Severe Injury

**Cause**: Failed hazard choice results in serious injury

**Result**: Increased death probability, reduced stats

**Recovery**: Rest at settlement or return home.

### Ambush Failure

**Cause**: Failed flee/fight choice

**Result**: Heirloom theft possible, severe injuries, time loss

**Recovery**: Accept loss, continue journey.

---

**Cross-References:**

- [Game Design](../GAME_DESIGN.md) • [Lore Bible](../LORE_BIBLE.md) • [Entropy System](entropy_and_endings.md) • [Player Guide](../PLAYER_GUIDE/travel_and_trade.md) • [Technical](../TECHNICAL/architecture_overview.md)

