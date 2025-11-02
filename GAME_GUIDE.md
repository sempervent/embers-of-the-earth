# Embers of the Earth - Game Implementation Guide

## Quick Start

This document provides an overview of the implemented systems and how to use them.

## Core Systems Implemented

### 1. Tile & Soil System (`Tile.gd`)

Each tile represents a piece of farmland with:
- **Soil Type**: ferro_soil, fungal_soil, ash_soil, pure_bio_soil, scrap_heap
- **Memory**: Tracks last crop, years of use, and mood (neutral, content, resentful, tired, exhausted)
- **Affinities**: Machine vs Nature affinity values (0.0 to 1.0)

**Key Methods:**
- `till_soil()` - Prepares tile for planting
- `plant_crop(crop_name)` - Plants a crop, updates soil memory
- `advance_growth()` - Advances crop growth by one day
- `harvest()` - Harvests mature crop, returns items, updates memory

### 2. Crop System (`Crop.gd`)

Crops are defined in `data/crops.json`:
- Growth stages and days per stage
- Requirements (iron, water, sunlight, etc.)
- Output items when harvested
- Soil preferences (likes/hates)

**Available Crops:**
- **Ironwheat**: 5 stages, 3 days each → grain, metal_scrap
- **Steamroot**: 4 stages, 4 days each → root_vegetable, steam_crystal
- **Cogbean**: 3 stages, 2 days each → bean, gear_scrap
- **Rustmoss**: 6 stages, 5 days each → moss, rust_powder

### 3. Player System (`Player.gd`)

Player character with:
- **Aging**: Ages one year per 120 game days
- **Traits**: Modify stats (strength, farming, crafting, etc.)
- **Inventory**: Item storage system
- **Bloodline**: Children list for succession

**Death System:**
- Death probability increases with age
- When player dies, control transfers to a child
- If no children exist, game ends

### 4. Game Manager (`GameManager.gd`)

Central game state manager:
- **Time System**: Tracks days, years, seasons
- **Auto-loaded**: Available globally via `GameManager.instance`
- **Save/Load**: JSON-based save system

**Time Progression:**
- 120 days = 1 year
- 4 seasons per year (spring, summer, autumn, winter)
- 30 days per season

### 5. Farm Grid (`FarmGrid.gd`)

Manages the 10x10 tile farm:
- Creates and maintains tile grid
- Handles tile interactions
- Advances all crops daily

### 6. Player Controller (`PlayerController.gd`)

Handles player movement and interaction:
- **Movement**: WASD/Arrow keys
- **Interaction**: E key
- **Auto-detection**: Automatically detects action (till/plant/harvest)

### 7. UI System (`GameUI.gd`)

Displays:
- Current date (Year, Day, Season)
- Player name and age
- Inventory items
- Advance Day button

## Gameplay Loop

1. **Move** - Use WASD or arrow keys to move around the farm
2. **Till** - Stand on untilled soil and press E to till it
3. **Plant** - Stand on tilled, empty soil and press E to plant a crop
4. **Wait** - Use "Advance Day" button to progress time
5. **Harvest** - When crops are mature, stand on them and press E to harvest
6. **Repeat** - Manage your farm, age, and eventually pass control to your children

## Data Files

All game data is in JSON format in `/data`:

- **crops.json** - Crop definitions
- **soil_types.json** - Soil type definitions
- **factions.json** - Faction data (for future implementation)
- **traits.json** - Character traits

## Extending the Game

### Adding a New Crop

Edit `data/crops.json`:

```json
{
  "name": "MyNewCrop",
  "growth_stages": 4,
  "requires": ["water", "sunlight"],
  "output": ["item1", "item2"],
  "likes": ["ferro_soil"],
  "hates": ["pure_bio_soil"],
  "days_per_stage": 3,
  "biomechanical": true,
  "description": "A new crop type"
}
```

### Adding a New Soil Type

Edit `data/soil_types.json`:

```json
{
  "name": "new_soil",
  "display_name": "New Soil",
  "machine_affinity_base": 0.5,
  "nature_affinity_base": 0.5,
  "description": "Description",
  "color": "#HEXCOLOR"
}
```

### Adding New Traits

Edit `data/traits.json`:

```json
{
  "name": "new_trait",
  "description": "Trait description",
  "stat_modifiers": {
    "stat_name": 2,
    "other_stat": -1
  }
}
```

## Next Steps for Expansion

The following systems are planned but not yet implemented:

1. **Travel System** - Overworld map, settlements
2. **Marriage System** - Marriage UI, child generation
3. **Trading System** - Buy/sell goods with factions
4. **Faction Reputation** - Relationship tracking
5. **NPCs** - Non-player characters for interaction
6. **Weather Events** - Random weather affecting crops
7. **Machine-God Events** - Mysterious occurrences

## Known Limitations

- No visual assets (uses placeholder sprites)
- No sound effects or music
- Basic UI (can be enhanced)
- Travel/settlement systems not implemented
- Marriage system not implemented
- Trading system not implemented

## Testing the Game

1. Open in Godot 4.2+
2. Run the farm scene
3. Move around with WASD
4. Press E to interact with tiles
5. Use "Advance Day" to progress time
6. Watch crops grow and harvest them

## Troubleshooting

**GameManager not found:**
- Ensure `GameManager` is set as autoload in `project.godot`
- Check the `[autoload]` section

**Tiles not visible:**
- Tiles are created programmatically
- Check the console for errors
- Ensure FarmGrid script is attached

**Crops not growing:**
- Ensure you're calling `advance_day()` in GameManager
- Check that `farm_grid` is assigned in GameManager
- Verify crop data in `crops.json`

---

*For detailed code documentation, see the script files in `/scripts` directory.*

