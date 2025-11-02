╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — FARMING SYSTEM        ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"The soil remembers. Plant the same crop year after year, and it will resent you. Rotate, and it grows content." — Soil Keeper's Manual*

---

## At a Glance

The farming system manages tile-based crop cultivation with soil memory, biomechanical plants, and mood-based yield modifiers. Every action alters soil memory. Neglect → resentment → exhaustion.

---

## What It Simulates

- **Tile Management**: 10×10 grid of farmable tiles
- **Soil Types**: 5 types with machine/nature affinity
- **Soil Memory**: Tracks crops planted, years used, mood
- **Crop Lifecycle**: Tilling → Planting → Growth → Harvest
- **Growth Mechanics**: Stage-based with time per stage
- **Yield Calculation**: Base output × soil mood × compatibility

---

## Data It Owns

### Tile State

Each tile stores:

```json
{
  "x": 0,
  "y": 0,
  "soil_type": "ferro_soil",
  "is_tilled": false,
  "current_crop": "Ironwheat",
  "crop_growth_stage": 3,
  "crop_days_in_stage": 2,
  "memory": {
    "last_crop": "Ironwheat",
    "years_used": 5,
    "mood": "resentful",
    "events": [...]
  },
  "machine_affinity": 0.7,
  "nature_affinity": 0.3
}
```

### Soil Types

```json
{
  "name": "ferro_soil",
  "machine_affinity_base": 0.7,
  "nature_affinity_base": 0.3,
  "description": "Metal-rich soil favoring biomechanical crops"
}
```

**Types**: `ferro_soil`, `fungal_soil`, `ash_soil`, `pure_bio_soil`, `scrap_heap`

### Crops

```json
{
  "name": "Ironwheat",
  "growth_stages": 5,
  "days_per_stage": 3,
  "requires": ["iron", "water", "sunlight"],
  "output": ["grain", "metal_scrap"],
  "likes": ["ferro_soil"],
  "hates": ["pure_bio_soil"],
  "biomechanical": true
}
```

---

## Signals & Events

- `tile_changed(tile)` — Emitted when tile state changes
- `crop_ready(tile)` — Emitted when crop reaches harvest stage
- `soil_mood_changed(tile, old_mood, new_mood)` — Emitted on mood transition

---

## Player-Facing Effects

### Tilling

- **Action**: Stand on untilled tile, press E
- **Effect**: Tile becomes tillable. Memory event logged.

### Planting

- **Action**: Stand on tilled tile, press E (select crop)
- **Effect**: Crop planted. Soil memory updated:
  - **Liked soil** → mood becomes "content"
  - **Hated soil** → mood becomes "resentful"
  - **Neutral soil** → mood remains "neutral"

### Growth

- **Automatic**: Each day advance, crops grow one day
- **Stages**: Crop progresses through growth stages
- **Time**: `days_per_stage` × `growth_stages` = total days

### Harvest

- **Action**: Stand on mature crop, press E
- **Effect**: 
  - Crop removed
  - Output items added to inventory
  - Soil memory updated (years_used++, mood may degrade)
  - Tile untilled (must retill)

---

## Soil Memory System

### Mood States

1. **Neutral** — Default state. No modifiers.
2. **Content** — Liked soil + compatible crop. +10% yield.
3. **Resentful** — Hated soil or repeated monoculture. -20% yield.
4. **Tired** — Years_used > 3. -10% yield.
5. **Exhausted** — Years_used > 5. -30% yield.

### Memory Events

Soil tracks:
- Crops planted (with mood impact)
- Growth stages reached
- Harvests completed
- Years used (cumulative)

**Example Memory**:
```json
{
  "last_crop": "Ironwheat",
  "years_used": 7,
  "mood": "exhausted",
  "events": [
    {"event": "planted_Ironwheat_happy", "day": 15},
    {"event": "grew_stage_3", "day": 24},
    {"event": "harvested", "day": 30}
  ]
}
```

---

## Growth Math

### Stage Progression

```
Day 0:   Plant crop → Stage 0
Day 3:   Advance → Stage 1 (if days_per_stage = 3)
Day 6:   Advance → Stage 2
Day 9:   Advance → Stage 3
Day 12:  Advance → Stage 4
Day 15:  Advance → Stage 5 (ready to harvest)
```

### Yield Calculation

```
Base Output: crop.output (e.g., grain: 3)
Soil Mood Modifier: 
  - Content: +10%
  - Neutral: +0%
  - Resentful: -20%
  - Tired: -10%
  - Exhausted: -30%
Soil Compatibility:
  - Liked soil: +20%
  - Neutral: +0%
  - Hated: -30%
Final Yield: Base × (1 + mood_mod + compat_mod)
```

---

## Balance Levers

- **Growth Speed**: `days_per_stage` (default: 3)
- **Mood Thresholds**: Years_used for tired/exhausted (default: 3/5)
- **Yield Modifiers**: Mood and compatibility bonuses/penalties
- **Soil Affinity**: Base machine/nature values per soil type

**Safe Tweaks**:
- Adjust `days_per_stage` (±1 day) for pacing
- Modify mood thresholds (±1 year) for difficulty
- Tune yield modifiers (±5%) for economy

**Risky Tweaks**:
- Changing soil affinity base values (affects all crops)
- Removing mood system (removes core mechanic)

---

## Failure Modes

### Soil Exhaustion

**Cause**: Repeatedly planting same crop, ignoring soil mood

**Symptoms**: All tiles resentful/exhausted. Crop yields near zero.

**Recovery**: Rotate crops, rest soil, use organic fertilizer

### Incompatible Crops

**Cause**: Planting biomechanical crop on pure_bio_soil (or vice versa)

**Symptoms**: Immediate resentful mood, -30% yield

**Recovery**: Plant compatible crops, wait for mood recovery

### Crop Death

**Cause**: Weather events, machine-god tremors, entropy events

**Symptoms**: Crop removed from tile mid-growth

**Recovery**: Replant, accept loss

---

## Example Crop Definition

```json
{
  "name": "Steamroot",
  "growth_stages": 4,
  "days_per_stage": 4,
  "requires": ["water", "heat"],
  "output": ["root_vegetable", "steam_crystal"],
  "likes": ["ferro_soil", "ash_soil"],
  "hates": ["fungal_soil"],
  "biomechanical": true,
  "description": "Generates internal steam pressure as it grows"
}
```

---

**Cross-References:**

- [Game Design](../GAME_DESIGN.md) • [Lore Bible](../LORE_BIBLE.md) • [Lineage System](lineage_system.md) • [Player Guide](../PLAYER_GUIDE/getting_started.md) • [Technical](../TECHNICAL/architecture_overview.md)

