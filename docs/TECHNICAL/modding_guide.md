╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — MODDING GUIDE         ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"Add crops, NPCs, events, buildings. The world expands through JSON. The code stays still. This is how we build." — Modder's Manual*

---

## At a Glance

This guide explains how to add new content to Embers of the Earth using JSON templates. No code changes required. Use the content templates to add crops, NPCs, events, and buildings without touching GDScript.

---

## Adding Content

### Using Templates

**Location**: `data/content_templates/`

**Templates Available**:
- `crop_template.json` — New crops
- `npc_template.json` — New NPCs
- `event_template.json` — New world events

**Process**:
1. Copy template file
2. Fill in fields
3. Add to appropriate JSON file
4. Game loads automatically

---

## Adding Crops

### Step 1: Copy Template

```bash
cp data/content_templates/crop_template.json data/crops/steelwheat.json
```

### Step 2: Fill in Fields

```json
{
  "name": "steelwheat",
  "growth_stages": 6,
  "days_per_stage": 3,
  "requires": ["iron", "steam", "water"],
  "output": {"grain": 3, "steel_scrap": 1},
  "likes": ["ferro_soil", "scrap_heap"],
  "hates": ["pure_bio_soil"],
  "biomechanical": true,
  "description": "A hardy crop that yields both sustenance and salvageable steel."
}
```

### Step 3: Add to Crops Array

**File**: `data/crops.json`

**Action**: Append new crop to array

**Example**:
```json
[
  {...existing crops...},
  {
    "name": "steelwheat",
    ...
  }
]
```

### Step 4: Reload

**Hot-Reload**: If ContentLoader supports hot-reload, changes apply immediately

**Manual Reload**: Restart game to load new crops

---

## Adding NPCs

### Step 1: Copy Template

```bash
cp data/content_templates/npc_template.json data/npcs/new_npc.json
```

### Step 2: Fill in Fields

```json
{
  "id": "thaddeus_forgehand",
  "name": "Thaddeus Forgehand",
  "faction": "machinists",
  "settlement": "brassford",
  "role": "smith",
  "age": 45,
  "schedule": {
    "morning": "workshop",
    "noon": "market",
    "evening": "tavern"
  },
  "opinions": {
    "Coalroot_bloodline": 0
  },
  "traits": ["strong", "grumpy"],
  "quotes": {
    "neutral": ["Metal doesn't lie. Neither do I."],
    "positive": ["Your family has honor. I respect that."],
    "negative": ["I remember your grandfather's broken contract."]
  }
}
```

### Step 3: Add to NPCs Array

**File**: `data/npcs/npcs.json`

**Action**: Append new NPC to array

---

## Adding World Events

### Step 1: Copy Template

```bash
cp data/content_templates/event_template.json data/world/events/new_event.json
```

### Step 2: Fill in Fields

```json
{
  "id": "plague_outbreak",
  "name": "Plague Outbreak",
  "trigger_conditions": {
    "min_year": 3,
    "chance_per_year": 0.05,
    "settlement_type": "any"
  },
  "effects": {
    "settlement": "random",
    "crop_damage": 30,
    "player_reputation_loss": -5
  },
  "rumors": [
    "They say a plague spreads. Crops wither. People flee."
  ],
  "journal_entries": [
    "A plague strikes. Crops die. The settlement suffers."
  ]
}
```

### Step 3: Add to Events Array

**File**: `data/world/events/world_events.json`

**Action**: Append new event to array

---

## Adding Buildings

### Create Building Definition

**File**: `data/buildings/buildings.json`

**Format**:
```json
{
  "id": "windmill_press",
  "name": "Windmill Press",
  "cost": {"wood": 40, "bolts": 10},
  "recipes": ["press_oil", "extract_essence"],
  "queue_limit": 3,
  "description": "Presses seeds to extract oil"
}
```

### Create Recipes

**File**: `data/buildings/recipes.json`

**Format**:
```json
{
  "id": "press_oil",
  "name": "Press Oil",
  "building_type": "windmill_press",
  "input": {"seeds": 10, "steam_energy": 3},
  "output": {"oil": 3},
  "time_days": 2
}
```

---

## Content Guidelines

### Naming Conventions

**Crops**: Descriptive + biomechanical (e.g., Steelwheat, Rustmoss)

**NPCs**: Name + role/faction (e.g., Thaddeus Forgehand)

**Events**: Verb + noun (e.g., Settlement Burns, Faction Collapse)

**Buildings**: Function + type (e.g., Steam Boiler, Grain Mill)

---

### Balancing Guidelines

**Crops**:
- 3-7 growth stages
- 2-5 days per stage
- Output balances with growth time

**NPCs**:
- 3-5 quotes per opinion level
- Ages between 20-80
- Traits match faction/role

**Events**:
- 5-15% chance per year for major events
- Effects balance with rarity
- Rumors match event significance

**Buildings**:
- Cost balances with benefits
- Recipe time balances with output
- Queue limits prevent overflow

---

## Hot-Reload System

### ContentLoader

**Location**: `scripts/content/ContentLoader.gd`

**Purpose**: Loads JSON files at runtime

**Hot-Reload**: If enabled, detects file changes and reloads

**Usage**: Modify JSON files while game is running (dev mode only)

---

## Testing New Content

### Manual Testing

1. Add content to JSON file
2. Reload game (or use hot-reload)
3. Verify content appears in game
4. Test functionality (plant crop, talk to NPC, trigger event)

### Automated Testing

**Location**: `scripts/qa/RegressionTester.gd`

**Usage**: Run regression tests to verify no systems break

**Command**: `run_all_tests()`

---

## Content Pack System

### Creating Content Packs

**Structure**:
```
my_content_pack/
├── manifest.json
├── crops.json
├── npcs.json
└── events.json
```

### Manifest Format

```json
{
  "id": "my_content_pack",
  "name": "My Content Pack",
  "version": "1.0.0",
  "author": "Your Name",
  "description": "Adds new crops, NPCs, and events",
  "dependencies": []
}
```

### Loading Content Packs

**Action**: Place pack in `assets/packs/` directory

**Auto-Load**: ContentLoader detects and loads packs

**Conflict Resolution**: User packs override base game content

---

**Cross-References:**

- [Content Pipelines](content_pipelines.md) • [File Structure](file_structure.md) • [Architecture Overview](architecture_overview.md) • [Game Design](../GAME_DESIGN.md)

