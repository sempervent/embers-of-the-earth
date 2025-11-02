╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — CONTENT PIPELINES     ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"Data flows from JSON to game state. Pipelines process content. Templates standardize format. The world expands through files." — Engineer's Manual*

---

## At a Glance

This document describes the content pipeline system: data formats, JSON schemas, loading order, and asset pack system. Written for contributors and modders.

---

## Data Format Standards

### JSON Structure

**Format**: UTF-8 JSON files

**Structure**: Arrays of objects (for collections) or single objects (for configs)

**Example**:
```json
[
  {
    "id": "item1",
    "name": "Item Name",
    "properties": {...}
  },
  {
    "id": "item2",
    ...
  }
]
```

---

## Data File Locations

### Core Data

**Crops**: `data/crops.json`  
**Soil Types**: `data/soil_types.json`  
**Factions**: `data/factions.json`  
**Traits**: `data/traits.json`

### Systems Data

**NPCs**: `data/npcs/npcs.json`  
**Events**: `data/world/events/world_events.json`  
**Heirlooms**: `data/heirlooms/heirlooms.json`  
**Settlements**: `data/world/settlements.json`  
**Buildings**: `data/buildings/buildings.json`  
**Recipes**: `data/buildings/recipes.json`

### RPG Data

**Traits**: `data/rpg/rpg_traits.json`  
**Stats**: `data/rpg/rpg_stats.json`  
**Titles**: `data/rpg/titles.json`

---

## JSON Schemas

### Crop Schema

```json
{
  "name": "string (required, unique)",
  "growth_stages": "integer (3-7)",
  "days_per_stage": "integer (2-5)",
  "requires": "array of strings (resources)",
  "output": "object {resource: quantity}",
  "likes": "array of strings (soil types)",
  "hates": "array of strings (soil types)",
  "biomechanical": "boolean",
  "description": "string"
}
```

---

### NPC Schema

```json
{
  "id": "string (required, unique)",
  "name": "string (required)",
  "faction": "string (required, must match faction id)",
  "settlement": "string (required, must match settlement id)",
  "role": "string",
  "age": "integer (20-80)",
  "schedule": {
    "morning": "string (location)",
    "noon": "string (location)",
    "evening": "string (location)"
  },
  "opinions": {
    "target_id": "integer (-100 to +100)"
  },
  "traits": "array of strings",
  "quotes": {
    "neutral": "array of strings",
    "positive": "array of strings",
    "negative": "array of strings",
    "rumor": "array of strings"
  }
}
```

---

### Event Schema

```json
{
  "id": "string (required, unique)",
  "name": "string (required)",
  "trigger_conditions": {
    "min_year": "integer",
    "max_year": "integer",
    "chance_per_year": "float (0.0-1.0)",
    "settlement_type": "string",
    "requires_entropy": "string (order/wild)",
    "entropy_threshold": "integer (0-100)"
  },
  "effects": {
    "settlement": "string (settlement id or 'random')",
    "price_multiplier": "float",
    "stock_reduction": "float (0.0-1.0)",
    "crop_damage": "integer (0-100)",
    "player_reputation_loss": "integer (-100 to +100)"
  },
  "rumors": "array of strings",
  "journal_entries": "array of strings"
}
```

---

## Loading Order

### Initialization Sequence

1. **DataLoader** loads all JSON files
2. **GameManager** initializes systems
3. **Systems** read from loaded data
4. **Game State** populated from data

### Dependency Order

**Base Data** (loads first):
- Crops
- Soil Types
- Factions
- Traits

**System Data** (loads after base):
- NPCs (depends on factions, settlements)
- Events (depends on settlements, factions)
- Buildings (depends on recipes)

**RPG Data** (loads after systems):
- RPG Traits (depends on base traits)
- Stats (depends on systems)
- Titles (depends on stats)

---

## Asset Pack System

### Pack Structure

```
content_pack/
├── manifest.json          # Pack metadata
├── crops.json              # New crops
├── npcs.json              # New NPCs
├── events.json            # New events
└── assets/              # Optional assets
    ├── sprites/
    └── sounds/
```

### Manifest Format

```json
{
  "id": "pack_unique_id",
  "name": "Pack Display Name",
  "version": "1.0.0",
  "author": "Author Name",
  "description": "Pack description",
  "dependencies": [],
  "conflicts": []
}
```

### Pack Loading

**Location**: `assets/packs/`

**Auto-Detection**: ContentLoader scans packs directory

**Load Order**: 
1. Base game content
2. User packs (alphabetical order)
3. Conflicts resolved (user packs override base)

---

## Naming Rules

### Identifiers

**Format**: `snake_case` (lowercase, underscores)

**Rules**:
- No spaces
- No special characters (except underscores)
- Must be unique within type

**Examples**:
- `ironwheat` ✓
- `Iron Wheat` ✗
- `iron-wheat` ✗
- `ironwheat_v2` ✓

---

### Display Names

**Format**: `Title Case` (capitalize each word)

**Rules**:
- Spaces allowed
- Special characters allowed (limited)
- Descriptive

**Examples**:
- `Iron Wheat` ✓
- `Steam-Root` ✓
- `Old Mara` ✓

---

## Data Validation

### Required Fields

**Crops**: name, growth_stages, requires, output  
**NPCs**: id, name, faction, settlement  
**Events**: id, name, trigger_conditions, effects

### Type Checking

**Integers**: Growth stages, ages, quantities  
**Floats**: Probabilities, multipliers (0.0-1.0)  
**Strings**: Names, descriptions, IDs  
**Arrays**: Lists of resources, quotes  
**Objects**: Nested data (output, schedule)

### Range Validation

**Opinions**: -100 to +100  
**Probabilities**: 0.0 to 1.0  
**Ages**: 20 to 80  
**Years**: 1 to 100+

---

## Content Hot-Reload

### File Watching

**Dev Mode**: ContentLoader watches JSON files

**Change Detection**: File modification time tracked

**Reload Trigger**: File change detected → reload content

**Usage**: Modify JSON files while game is running (dev builds only)

---

## Export Pipeline

### Asset Processing

**Sprites**: Generated from templates (procedural)

**Audio**: Processed from source files (compression)

**Data**: Validated JSON files

### Build Pipeline

1. **Validate** all JSON files
2. **Process** assets (sprites, audio)
3. **Pack** content into game build
4. **Test** content loading

---

**Cross-References:**

- [Modding Guide](modding_guide.md) • [File Structure](file_structure.md) • [Save System](save_system.md) • [Architecture Overview](architecture_overview.md)

