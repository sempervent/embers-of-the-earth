# Modding Guide - Embers of the Earth

## Overview

Embers of the Earth is designed to be moddable through JSON data files and content packs. You can modify game content without editing code.

## Data File Structure

### Crops (`data/crops.json`)

```json
{
  "name": "Ironwheat",
  "growth_stages": 5,
  "requires": ["iron", "water", "sunlight"],
  "output": ["grain", "metal_scrap"],
  "likes": ["ferro_soil"],
  "hates": ["pure_bio_soil"],
  "days_per_stage": 3,
  "biomechanical": true,
  "description": "A hardy crop"
}
```

**Keys:**
- `name`: Unique crop identifier
- `growth_stages`: Number of growth stages
- `requires`: Array of required resources
- `output`: Array of items produced when harvested
- `likes`: Array of preferred soil types
- `hates`: Array of incompatible soil types
- `days_per_stage`: Days per growth stage
- `biomechanical`: Boolean (affects entropy)
- `description`: Display description

### Soil Types (`data/soil_types.json`)

```json
{
  "name": "ferro_soil",
  "display_name": "Ferro Soil",
  "machine_affinity_base": 0.7,
  "nature_affinity_base": 0.3,
  "description": "Metal-rich soil",
  "color": "#8B7355"
}
```

**Keys:**
- `name`: Unique soil identifier
- `display_name`: Human-readable name
- `machine_affinity_base`: Machine affinity (0.0-1.0)
- `nature_affinity_base`: Nature affinity (0.0-1.0)
- `description`: Display description
- `color`: Hex color code

### Factions (`data/factions.json`)

```json
{
  "name": "machinists",
  "display_name": "Brass Guild",
  "offers": ["steam_prosthetics", "gear_blueprints"],
  "requires": ["ironwheat_tribute", "marriage_alliance"],
  "marriage_benefits": {
    "traits": ["mechanically_gifted"],
    "dowry": ["gear_blueprint"]
  },
  "reputation_needed": 30,
  "description": "Master craftspeople"
}
```

### Encounters (`data/world/encounters.json`)

```json
{
  "id": "bandits",
  "name": "Desperate Bandits",
  "weight": 6,
  "description": "A group blocks your path.",
  "effects": {
    "lose_items": ["grain"],
    "injury": "cut"
  }
}
```

**Keys:**
- `id`: Unique encounter identifier
- `name`: Display name
- `weight`: Encounter probability weight
- `description`: Display description
- `effects`: Dictionary of effects (lose_items, gain_items, injury, etc.)

### Hazards (`data/world/hazards.json`)

```json
{
  "id": "bandits_road",
  "name": "Bandit Ambush",
  "description": "Bandits block your path.",
  "choices": [
    {
      "id": "fight",
      "name": "Fight",
      "requires": {
        "traits": ["strong"],
        "items": {"weapons": 1}
      },
      "success_chance": 0.7,
      "success": {"reputation_gain": 5},
      "failure": {"injury": "cut"}
    }
  ]
}
```

### Buildings (`data/buildings/buildings.json`)

```json
{
  "id": "boiler",
  "name": "Steam Boiler",
  "cost": {
    "metal_scrap": 20,
    "gear_scrap": 10
  },
  "size": {"width": 2, "height": 2},
  "recipes": ["steam_generation"]
}
```

### Recipes (`data/buildings/recipes.json`)

```json
{
  "building": "boiler",
  "name": "Steam Generation",
  "in": {
    "steamroot": 5,
    "fuel": 2
  },
  "out": {
    "steam": 8
  },
  "time": 1,
  "description": "Generates steam"
}
```

### Marriage Terms (`data/marriage_terms.json`)

```json
{
  "faction": "machinists",
  "dowry": {
    "items": {"gear_blueprint": 1}
  },
  "obligations": {
    "tribute": {"ironwheat": 50}
  },
  "benefits": {
    "tech": ["auto_harvester"],
    "reputation": {"machinists": 25}
  }
}
```

### Awakening Events (`data/narrative/awakening_events.json`)

```json
{
  "id": "steam_surge",
  "path": "order",
  "threshold": 25,
  "name": "Steam Surge",
  "description": "The machine-god stirs.",
  "effects": {
    "spawn_steam_vents": 3,
    "weather": "steam_fog"
  }
}
```

## Content Packs

Content packs allow adding/replacing assets without modifying core files.

### Pack Structure

```
assets/packs/<pack_name>/
├── manifest.json
├── sprites/
│   ├── crops/
│   ├── tiles/
│   └── characters/
├── audio/
│   ├── ambient/
│   ├── music/
│   └── sfx/
└── shaders/
```

### Manifest Format (`manifest.json`)

```json
{
  "sprites": {
    "crops": ["ironwheat_*.png"],
    "tiles": ["soil_*.png"]
  },
  "audio": {
    "ambient": ["wind01.ogg"],
    "music": ["layer_banjo.ogg"]
  },
  "shaders": ["dust.gdshader"]
}
```

**Keys:**
- `sprites`: Dictionary mapping sprite categories to file arrays
- `audio`: Dictionary mapping audio categories to file arrays
- `shaders`: Array of shader file names

### Creating a Content Pack

1. Create directory: `assets/packs/<pack_name>/`
2. Add `manifest.json` with asset references
3. Place assets in subdirectories
4. Pack loads automatically on game start

### Hot-Reloading

Use dev console command (if implemented):
```
reload_content_packs
```

Or call from code:
```gdscript
var content_loader = get_tree().get_first_node_in_group("content") as ContentLoader
content_loader.reload_packs()
```

## JSON Schema Reference

### Common Patterns

**Items Dictionary:**
```json
{"item_id": quantity}
```

**Effects Dictionary:**
```json
{
  "lose_items": ["item1", "item2"],
  "gain_items": {"item3": 5},
  "injury": "cut",
  "reputation_gain": 5
}
```

**Requirements Dictionary:**
```json
{
  "traits": ["strong", "diplomatic"],
  "items": {"weapons": 1},
  "stats": {"strength": 10}
}
```

**Choices Array:**
```json
[
  {
    "id": "choice_id",
    "name": "Choice Name",
    "requires": {...},
    "success_chance": 0.7,
    "success": {...},
    "failure": {...}
  }
]
```

## Modding Best Practices

1. **Backup Original Files**: Always backup before modifying
2. **Test Incrementally**: Add changes one at a time
3. **Validate JSON**: Use a JSON validator before testing
4. **Version Control**: Track your changes with git
5. **Documentation**: Document custom additions

## Mod Distribution

To share your mod:

1. Package as content pack (use manifest.json)
2. Or provide modified JSON files
3. Include README with instructions
4. Test compatibility with base game

## Advanced Modding

### Custom Scripts

While the game loads data from JSON, custom behaviors require GDScript:

1. Extend existing classes
2. Override methods as needed
3. Hook into signals

### Save Compatibility

Mods that change data structures may break saves:

1. Increment schema version in SaveSchema.gd
2. Add migration logic
3. Document breaking changes

## Troubleshooting

**Mod not loading:**
- Check JSON syntax (validate with JSON linter)
- Verify file paths match manifest
- Check console for errors

**Assets not appearing:**
- Verify asset paths in manifest
- Check file formats (PNG, OGG, etc.)
- Ensure assets are in correct subdirectories

**Save file errors:**
- Backup saves before modding
- Check schema version compatibility
- Clear saves if needed

## Resources

- JSON Schema Validator: https://json-schema.org/
- Godot Asset Formats: https://docs.godotengine.org/
- Game Data Files: `data/` directory

---

For questions or issues, see main README.md or open an issue on GitHub.

