╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — SAVE SYSTEM           ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"The save file remembers. Every day, every choice, every generation. The state persists. The world continues. Your legacy is written in JSON." — Engineer's Manual*

---

## At a Glance

This document describes the save system architecture: schema versioning, serialization format, autosave mechanics, and migration procedures. Written for developers and contributors.

---

## Save Schema

### Schema Version

**Format**: `schema_version: integer`

**Purpose**: Version tracking for migration compatibility

**Current Version**: `1.0`

**Usage**: Migration scripts check version to apply appropriate transformations

---

### Save File Structure

```json
{
  "schema_version": 1,
  "timestamp": 1234567890,
  "game_state": {
    "current_year": 5,
    "current_day": 120,
    "current_season": "winter",
    "player": {...},
    "farm_grid": {...},
    "npcs": {...},
    "entropy": {...},
    "lineage": {...}
  }
}
```

---

## Serialization

### GameManager State

**Saves**:
- Current year
- Current day
- Current season
- Player reference

**Location**: `scripts/GameManager.gd`

**Method**: `serialize_game_state()`

---

### Player State

**Saves**:
- Name
- Age
- Generation
- Traits
- Stats (Resolve, Mechanica, Soilcraft, Diplomacy, Vigor)
- Inventory
- Heirlooms
- Faction relations
- Injuries

**Location**: `scripts/Player.gd`

**Method**: `serialize_player_state()`

---

### Farm Grid State

**Saves**:
- Tile states (10×10 grid)
- Crop data per tile
- Soil memory per tile
- Building positions

**Location**: `scripts/FarmGrid.gd`

**Method**: `serialize_farm_state()`

---

### NPC State

**Saves**:
- NPC opinions
- Memory events
- Current locations
- Ages

**Location**: `scripts/npcs/NPCSystem.gd`

**Method**: `serialize_npc_state()`

---

### Entropy State

**Saves**:
- Order level (0-100)
- Wild level (0-100)
- History (events, milestones)
- Triggered endings

**Location**: `scripts/narrative/EntropySystem.gd`

**Method**: `serialize_entropy_state()`

---

### Lineage State

**Saves**:
- Family tree (generations)
- Marriage contracts
- Heir data
- Trait inheritance history

**Location**: `scripts/family/LineageSystem.gd`

**Method**: `serialize_lineage_state()`

---

## Autosave System

### Rolling Saves

**Count**: 3 autosave slots

**Frequency**: Every 10 days (configurable)

**Format**: `autosave_0.json`, `autosave_1.json`, `autosave_2.json`

**Rotation**: Oldest save overwritten

---

### CRC Verification

**Purpose**: Detect save file corruption

**Method**: CRC32 checksum appended to save file

**Validation**: Load system verifies checksum before deserialization

**Failure**: If checksum fails, load next autosave

---

### Manual Saves

**Slots**: 5 save slots

**Format**: `save_0.json` through `save_4.json`

**Player Action**: Press Save → Choose slot → Confirm

**Overwrite**: Manual saves can overwrite previous saves

---

## Save File Format

### Complete Schema

```json
{
  "schema_version": 1,
  "timestamp": 1234567890,
  "crc": "a1b2c3d4",
  "game_state": {
    "current_year": 5,
    "current_day": 120,
    "current_season": "winter",
    "player_state": {
      "name": "Elias Coalroot",
      "age": 43,
      "generation": 1,
      "traits": ["ironblood", "soilbound"],
      "stats": {
        "resolve": 15,
        "mechanica": 12,
        "soilcraft": 18,
        "diplomacy": 10,
        "vigor": 14
      },
      "inventory": {
        "food": 50,
        "fuel": 30,
        "water": 40,
        "metal_scrap": 20
      },
      "heirlooms": ["first_farmers_letter", "cracked_music_locket"],
      "faction_relations": {
        "machinists": 20,
        "root_keepers": -10
      },
      "injuries": []
    },
    "farm_state": {
      "tiles": [...],
      "buildings": [...]
    },
    "npc_state": {
      "npcs": {...}
    },
    "entropy_state": {
      "order_level": 45,
      "wild_level": 30,
      "history": [...],
      "milestones": [...]
    },
    "lineage_state": {
      "generations": [...],
      "marriage_contracts": [...]
    }
  }
}
```

---

## Migration System

### Version Checking

**On Load**: Check `schema_version` in save file

**If Mismatch**: Run migration script

**Migration Scripts**: Located in `scripts/systems/migrations/`

**Format**: `migration_v1_to_v2.gd`

---

### Migration Example

**From Version 1.0 to 1.1**:

```gdscript
func migrate_v1_to_v1_1(save_data: Dictionary) -> Dictionary:
    # Add new field
    if not save_data.has("new_field"):
        save_data["new_field"] = default_value
    
    # Update schema version
    save_data["schema_version"] = 1.1
    
    return save_data
```

---

## Save/Load Procedures

### Saving

1. **Collect State**: All systems serialize their state
2. **Merge**: Combine into single save structure
3. **Calculate CRC**: Compute checksum
4. **Write File**: Save to `user://save_N.json`
5. **Verify**: Read back and verify CRC

---

### Loading

1. **Read File**: Load JSON from `user://save_N.json`
2. **Verify CRC**: Check checksum
3. **Check Version**: Compare schema version
4. **Migrate**: Run migration if needed
5. **Deserialize**: All systems restore their state
6. **Initialize**: Restore game state

---

## Error Handling

### Corrupted Saves

**Detection**: CRC mismatch

**Recovery**: Load next autosave slot

**If All Corrupted**: Start new game (last resort)

---

### Missing Fields

**Detection**: Required field missing in save

**Recovery**: Use default values

**Logging**: Log missing fields for debugging

---

### Version Mismatch

**Detection**: Schema version doesn't match current

**Recovery**: Run migration script

**If Migration Fails**: Warn user, offer to load older version or start new game

---

## Best Practices

### Save Frequency

**Autosave**: Every 10 days (balance between safety and performance)

**Manual Save**: Before risky actions (travel, major choices)

**Quicksave**: Not implemented (consider for future)

---

### Save Size

**Target**: <1MB per save file

**Optimization**: 
- Don't save procedural data (regenerate on load)
- Compress large arrays if possible
- Remove redundant data

---

### Save Validation

**On Save**: Validate all data before writing

**On Load**: Verify data integrity after loading

**Errors**: Log errors, warn user, offer recovery options

---

**Cross-References:**

- [Architecture Overview](architecture_overview.md) • [File Structure](file_structure.md) • [Content Pipelines](content_pipelines.md) • [Game Design](../GAME_DESIGN.md)

