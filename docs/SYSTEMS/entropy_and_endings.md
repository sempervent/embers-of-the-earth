╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — ENTROPY & ENDINGS    ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"When Order reaches 75, the machine-god stirs. When Wild reaches 75, nature spreads. Choose wisely. Or don't. The ending chooses itself." — Entropy Codex*

---

## At a Glance

The entropy system tracks two opposing paths (Order vs Wild) based on player actions. Reaching 75% on either path triggers an ending. The system generates epilogues, family tree summaries, and legacy reflections.

---

## What It Simulates

- **Dual Meters**: Order (0-100) and Wild (0-100)
- **Milestone Tracking**: Major events push entropy
- **Ending Triggers**: 75% on either path → ending
- **Epilogue Generation**: Family tree, final rumors, missing heirlooms
- **Legacy Reflection**: Statistics, NPC memories, player choices

---

## Data It Owns

### Entropy State

```json
{
  "order_level": 45,
  "wild_level": 30,
  "history": [
    {"event": "planted_biomechanical_crop", "order": +2, "wild": -1, "day": 15},
    {"event": "built_machine_building", "order": +5, "wild": -3, "day": 42},
    {"event": "arranged_nature_marriage", "order": -3, "wild": +5, "day": 67}
  ],
  "milestones": [
    {"type": "order", "threshold": 25, "reached_day": 42},
    {"type": "order", "threshold": 50, "reached_day": 120}
  ]
}
```

### Ending State

```json
{
  "triggered": true,
  "type": "order",
  "order_level": 78,
  "wild_level": 22,
  "trigger_day": 350,
  "epilogue": {
    "monologue": "...",
    "family_tree": {...},
    "final_rumors": [...],
    "missing_heirlooms": [...],
    "npc_memories": {...},
    "statistics": {...}
  }
}
```

---

## Signals & Events

- `entropy_changed(order, wild)` — Emitted when entropy levels change
- `entropy_milestone_reached(type, threshold)` — Emitted when milestone reached (25, 50, 75)
- `ending_triggered(ending_type, ending_data)` — Emitted when ending triggers
- `epilogue_ready(epilogue_data)` — Emitted when epilogue generated

---

## Player-Facing Effects

### Order Path

**Actions That Push Order**:
- Plant biomechanical crops (+2 per crop)
- Build machine buildings (+5 per building)
- Arrange faction marriages with machinists (+3 per marriage)
- Use steam-powered tools (+1 per use)

**Effects**:
- Machine buildings more efficient
- Biomechanical crops yield more
- Faction reputation with machinists increases
- Wild soil becomes less fertile

### Wild Path

**Actions That Push Wild**:
- Plant biological crops (+2 per crop)
- Preserve pure soil (+5 per preservation)
- Arrange nature-aligned marriages (+3 per marriage)
- Reject machine technology (+1 per rejection)

**Effects**:
- Biological crops yield more
- Pure soil stays fertile
- Faction reputation with Root Keepers increases
- Machine buildings become less efficient

### Dual Path Management

**Balanced Play**: Keeping both meters <50 delays endings but limits benefits

**Committed Play**: Pushing one meter >50 unlocks path-specific benefits but accelerates ending

**Extreme Play**: Reaching 75% triggers ending immediately

---

## Ending Types

### 1. The Machine-God Awakens (Order >75)

**Trigger**: Order entropy reaches 75

**Monologue**: *"After {generations} generations, the machine-god has awakened. Your bloodline chose iron over life. The great machine beneath the earth stirs. All soil turns to metal. All life becomes machine."*

**Epilogue**:
- Family tree shows generations of machine-builders
- Final rumors: "The Coalroots brought the machine-god's awakening."
- Missing heirlooms: Biological heirlooms lost or destroyed
- NPC memories: Machinists praise, Root Keepers curse
- Statistics: Total machine buildings, biomechanical crops, Order entropy

---

### 2. Nature's Triumph (Wild >75)

**Trigger**: Wild entropy reaches 75

**Monologue**: *"After {generations} generations, nature has reclaimed the land. Your bloodline chose life over machine. The wild spreads. Machines rust. Pure soil grows where steel once stood."*

**Epilogue**:
- Family tree shows generations of nature-preservers
- Final rumors: "The Coalroots saved the soil from machines."
- Missing heirlooms: Machine heirlooms lost or rusted
- NPC memories: Root Keepers praise, Machinists curse
- Statistics: Total biological crops, pure soil preserved, Wild entropy

---

### 3. The Bloodline Ends (Extinction)

**Trigger**: Player dies with no eligible heirs

**Monologue**: *"The last of the {family_name} is gone. The bloodline ends. The earth forgets. No heirs. No future. The legacy dies with you."*

**Epilogue**:
- Family tree shows incomplete lineage
- Final rumors: "The Coalroots are gone. The farm lies abandoned."
- Missing heirlooms: All heirlooms lost forever
- NPC memories: NPCs remember the fallen bloodline
- Statistics: Years played, generations reached, cause of extinction

---

### 4. The Wandering Path (NPC Mode)

**Trigger**: Player abandons farm (special action)

**Monologue**: *"You left the farm. The road calls. Your bloodline continues elsewhere. The farm is sold. You wander. Stories spread of the {family_name} who left the land."*

**Epilogue**:
- Family tree shows wandering branch
- Final rumors: "The Coalroots became wanderers. Their legacy is in stories."
- Missing heirlooms: Farm heirlooms stay at farm
- NPC memories: NPCs remember the wandering farmer
- Statistics: Travel distance, settlements visited, years wandering

---

## Entropy Calculation

### Event Contributions

**Planting Biomechanical Crop**:
- Order: +2
- Wild: -1

**Planting Biological Crop**:
- Order: -1
- Wild: +2

**Building Machine Building**:
- Order: +5
- Wild: -3

**Preserving Pure Soil**:
- Order: -3
- Wild: +5

**Arranging Machinist Marriage**:
- Order: +3
- Wild: -2

**Arranging Root Keeper Marriage**:
- Order: -2
- Wild: +3

### Milestone Tracking

**Thresholds**: 25, 50, 75

**Effects**:
- 25: Minor faction opinion boost
- 50: Major faction opinion boost, path-specific benefits unlock
- 75: Ending triggers

---

## Epilogue Generation

### Family Tree Summary

```json
{
  "total_generations": 4,
  "generations": [
    {"generation": 1, "name": "Elias Coalroot", "age": 53, "year": 35},
    {"generation": 2, "name": "Iris Coalroot", "age": 48, "year": 68},
    {"generation": 3, "name": "Marcus Coalroot", "age": 52, "year": 115},
    {"generation": 4, "name": "Luna Coalroot", "age": 45, "year": 160}
  ]
}
```

### Final Rumors

Array of rumor strings about the bloodline's legacy:
- *"The Coalroots brought the machine-god's awakening."*
- *"Some say the Coalroot family still tends the old farm."*
- *"The stories of the Coalroots will fade, but never disappear."*

### Missing Heirlooms

Array of heirloom names that were lost:
- *"The First Farmer's Letter was stolen by bandits."*
- *"The Cracked Music Locket rusted away."*

### NPC Memories

Dictionary of NPC final quotes:
```json
{
  "mara_old": {
    "opinion": -20,
    "quote": "The Coalroots broke contracts. Their shame echoes through generations."
  },
  "thaddeus_forgehand": {
    "opinion": 30,
    "quote": "The Coalroots built machines. Their legacy is steel and steam."
  }
}
```

### Final Statistics

```json
{
  "years_played": 160,
  "days_played": 19200,
  "generations": 4,
  "crops_harvested": 1200,
  "trades_completed": 85,
  "marriages": 6,
  "buildings_placed": 12,
  "travel_distance": 5000,
  "final_order_entropy": 78,
  "final_wild_entropy": 22
}
```

---

## Balance Levers

- **Entropy Gains**: Per-action values (+1 to +5)
- **Milestone Thresholds**: 25, 50, 75 (fixed)
- **Ending Threshold**: 75% (fixed)
- **Epilogue Content**: Generated from game state

**Safe Tweaks**:
- Adjust per-action entropy gains (±1)
- Modify milestone effects (opinion bonuses)

**Risky Tweaks**:
- Changing ending threshold (breaks design)
- Removing dual-path system (removes core mechanic)

---

## Failure Modes

### Unwinnable State

**Cause**: All soil exhausted, no food, can't travel

**Result**: Player can't continue. Soft fail → extinction ending.

**Recovery**: None. New game required.

### No Ending Reached

**Cause**: Player dies before reaching 75% entropy

**Result**: Extinction ending triggers instead

**Recovery**: None. Ending still generates epilogue.

---

**Cross-References:**

- [Game Design](../GAME_DESIGN.md) • [Lore Bible](../LORE_BIBLE.md) • [Lineage System](lineage_system.md) • [Player Guide](../PLAYER_GUIDE/lineage_and_heirs.md) • [Technical](../TECHNICAL/architecture_overview.md)

