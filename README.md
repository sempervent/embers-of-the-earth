# Embers of the Earth

A post-apocalyptic steampunk farming sim with generational bloodlines, biomechanical crops, soil memory, and travel to nearby settlements for trade and arranged marriages.

## Overview

**Embers of the Earth** is a pixel-art game built with Godot 4.x that combines farming simulation with generational gameplay. Manage your farm across multiple generations, tend to biomechanical crops that remember their past, and negotiate with factions through trade and marriage alliances.

## Features

### Core Systems

- **Soil & Tile System** - Each tile stores soil type, memory of past crops, and affinity for machine vs nature
- **Biomechanical Crops** - Plants that require metal, steam, and mechanical parts to grow
- **Soil Memory** - Tiles remember what was planted and how they were used, affecting future yields
- **Generational Bloodlines** - Players age and die, passing control to their children
- **Settlement Travel** - Visit nearby settlements for trade and arranged marriages
- **Faction Diplomacy** - Form alliances through marriage contracts

### Current Build Status

✅ **Implemented:**
- Tile-based farm scene with player movement
- Tilling, planting, and harvesting mechanics
- Soil memory system that tracks crop history
- Player aging and death system
- Basic UI (inventory, date, player age)
- JSON data loaders for crops, soil types, factions, and traits
- Save/load game system

🚧 **Planned:**
- Travel system to settlements
- Marriage and family generation UI
- Trading system
- Overworld map
- Weather and machine-god systems
- Pixel art assets

## Project Structure

```
embers-of-the-earth/
├── assets/          # Sprites, tiles, UI, sounds
│   ├── sprites/
│   ├── tiles/
│   ├── ui/
│   └── sounds/
├── scripts/         # Game logic
│   ├── Tile.gd             # Soil and memory system
│   ├── Crop.gd          # Crop definitions
│   ├── Player.gd            # Player character with aging
│   ├── GameManager.gd      # Main game state manager
│   ├── FarmGrid.gd         # Farm grid management
│   ├── PlayerController.gd # Player movement and interaction
│   ├── GameUI.gd           # UI controller
│   ├── FarmScene.gd        # Main farm scene
│   └── DataLoader.gd       # JSON file loader utility
├── scenes/          # Godot scenes
│   └── farm.tscn          # Main farm scene
├── data/            # JSON data files
│   ├── crops.json         # Crop definitions
│   ├── soil_types.json    # Soil type definitions
│   ├── factions.json      # Faction data
│   └── traits.json        # Character traits
└── project.godot    # Godot project configuration
```

## Getting Started

### Requirements

- **Godot 4.2+** (or compatible version)
- **Platform:** Windows, macOS, or Linux

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/embers-of-the-earth.git
   cd embers-of-the-earth
   ```

2. Open the project in Godot:
   - Launch Godot 4.2+
   - Click "Import" or "Open"
   - Navigate to the project folder and select `project.godot`

3. Run the game:
   - Press F5 or click the Play button
   - The main farm scene will load

### Controls

- **Arrow Keys / WASD** - Move player character
- **E** - Interact with tile (till, plant, harvest)
- **Advance Day Button** - Progress time by one day

### Gameplay Basics

1. **Farming:**
   - Move to a tile and press E to till soil
   - Till soil first, then plant a crop
   - Crops grow over multiple days
   - Harvest when crops reach full maturity

2. **Soil Types:**
   - **Ferro Soil** - Best for biomechanical crops
   - **Fungal Soil** - Favors biological growth
   - **Ash Soil** - Neutral, accepts both types
   - **Pure Bio Soil** - Rejects mechanical crops
   - **Scrap Heap** - Piles of machinery, hardest biomechanical crops only

3. **Crops:**
   - **Ironwheat** - Yields grain and metal scrap (5 stages, 3 days each)
   - **Steamroot** - Yields root vegetable and steam crystals (4 stages, 4 days each)
   - **Cogbean** - Yields beans and gear scrap (3 stages, 2 days each)
   - **Rustmoss** - Slow-growing, consumes metal (6 stages, 5 days each)

4. **Player Aging:**
   - Players age one year per 120 days (1 game year)
   - Death probability increases with age
   - When you die, control transfers to a child (if available)

## Data Files

All game data is stored in JSON files in the `/data` directory:

### `crops.json`
Defines crop types, growth stages, requirements, and outputs.

### `soil_types.json`
Defines soil types with machine/nature affinity values.

### `factions.json`
Faction definitions with offers, requirements, and marriage benefits.

### `traits.json`
Character traits that modify player stats.

## Development

### Adding New Crops

Edit `data/crops.json` and add a new crop definition:

```json
{
  "name": "NewCrop",
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

### Adding New Soil Types

Edit `data/soil_types.json` and add a new soil definition:

```json
{
  "name": "new_soil",
  "display_name": "New Soil",
  "machine_affinity_base": 0.5,
  "nature_affinity_base": 0.5,
  "description": "Description of the soil",
  "color": "#HEXCOLOR"
}
```

### Customization

The game is designed to be easily customizable through JSON data files. Modify the data files to add new content without changing code.

## Style & Atmosphere

- **Art Style:** Pixel art (16x16 or 32x32 tiles)
- **Color Palette:** Muted copper, orange, ash tones
- **Atmosphere:** Slightly dying, rusting, post-apocalyptic steampunk
- **UI:** Brass frames, cracked metal textures
- **No bright colors** - Everything has a worn, weathered feel

## Roadmap

- [ ] Travel system to settlements
- [ ] Marriage and family generation UI
- [ ] Trading system with factions
- [ ] Overworld map generation
- [ ] Weather and machine-god events
- [ ] NPC interaction system
- [ ] Pixel art assets
- [ ] Sound effects and ambient music
- [ ] Advanced soil memory mechanics
- [ ] Faction reputation system

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

Built with [Godot Engine](https://godotengine.org/)

---

*In the ashes of the old world, new life grows. Tend your fields, build your bloodline, and remember: the soil never forgets.*
