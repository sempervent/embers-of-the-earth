╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — FILE STRUCTURE        ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"Every file has its place. Every script connects. Every asset belongs. The repository is a map of the game's soul." — Developer's Codex*

---

## At a Glance

This document describes the repository structure of Embers of the Earth: top-level directories, notable files, and organization patterns. Written for contributors and modders.

---

## Repository Tree

```
embers-of-the-earth/
├── assets/
│   ├── generated/      # Procedurally generated sprites
│   ├── packs/         # Content packs (mods)
│   ├── sprites/       # Crop sprites, NPC portraits
│   ├── tiles/         # Soil tile textures
│   ├── ui/            # UI elements, buttons, panels
│   └── sounds/        # Audio files (music, ambient, SFX)
├── data/
│   ├── crops.json              # Crop definitions
│   ├── soil_types.json         # Soil type definitions
│   ├── factions.json           # Faction definitions
│   ├── traits.json             # Player trait definitions
│   ├── marriage_terms.json     # Marriage contract templates
│   ├── heirlooms/
│   │   └── heirlooms.json      # Heirloom definitions
│   ├── npcs/
│   │   └── npcs.json           # NPC definitions
│   ├── rpg/
│   │   ├── rpg_traits.json      # RPG trait definitions
│   │   ├── rpg_stats.json       # Stat definitions
│   │   └── titles.json          # Title definitions
│   ├── world/
│   │   ├── regions.json          # Region definitions
│   │   ├── encounters.json       # Encounter definitions
│   │   ├── settlements.json      # Settlement definitions
│   │   ├── goods.json            # Trade good definitions
│   │   ├── hazards.json          # Hazard definitions
│   │   └── events/
│   │       └── world_events.json # World event definitions
│   ├── buildings/
│   │   ├── buildings.json        # Building definitions
│   │   └── recipes.json         # Recipe definitions
│   ├── narrative/
│   │   └── awakening_events.json # Entropy milestone events
│   ├── slices/
│   │   └── alpha_vertical.json  # Vertical slice configuration
│   ├── family_identity/
│   │   └── origins.json         # Family origin definitions
│   ├── content_templates/
│   │   ├── crop_template.json    # Crop template
│   │   ├── npc_template.json    # NPC template
│   │   └── event_template.json # Event template
│   └── prologue/
│       └── first_winter_letter.json # Prologue text
├── scripts/
│   ├── Tile.gd                  # Tile class
│   ├── Crop.gd                  # Crop class
│   ├── Player.gd                # Player class
│   ├── GameManager.gd           # Central game manager (singleton)
│   ├── FarmGrid.gd              # Farm grid manager
│   ├── PlayerController.gd      # Player movement/interaction
│   ├── GameUI.gd                # UI manager
│   ├── FarmScene.gd             # Farm scene controller
│   ├── DataLoader.gd            # JSON file loader
│   ├── atmosphere/
│   │   ├── AtmosphereManager.gd # Atmosphere coordinator
│   │   └── JournalSystem.gd    # Journal entry system
│   ├── audio/
│   │   ├── ProceduralMusic.gd  # Procedural music system
│   │   └── AmbientSoundManager.gd # Ambient audio manager
│   ├── weather/
│   │   └── WeatherSystem.gd    # Weather system
│   ├── visual/
│   │   └── VisualEffects.gd    # Visual effects manager
│   ├── world/
│   │   ├── WorldController.gd  # Overworld manager
│   │   ├── EncounterTable.gd   # Encounter table system
│   │   └── HazardResolver.gd  # Hazard choice resolver
│   ├── world/events/
│   │   ├── RumorSystem.gd       # Rumor system
│   │   └── WorldEventSystem.gd # World event system
│   ├── settlement/
│   │   └── SettlementController.gd # Settlement manager
│   ├── family/
│   │   └── LineageSystem.gd    # Lineage succession system
│   ├── buildings/
│   │   └── ProductionSystem.gd  # Production system
│   ├── narrative/
│   │   └── EntropySystem.gd     # Entropy system
│   ├── npcs/
│   │   ├── NPCSystem.gd         # NPC system
│   │   └── HeirloomSystem.gd   # Heirloom system
│   ├── rpg/
│   │   ├── RPGStatsSystem.gd    # RPG stats system
│   │   ├── TitleSystem.gd       # Title system
│   │   └── FamilyIdentitySystem.gd # Family identity system
│   ├── ui/
│   │   ├── TutorialDirector.gd # Tutorial system
│   │   ├── TutorialOverlay.gd   # Tutorial overlay
│   │   ├── CharacterCreation.gd # Character creation
│   │   ├── PrologueSequence.gd # Prologue system
│   │   ├── InputMapper.gd       # Input mapping
│   │   ├── RadialMenu.gd        # Radial menu
│   │   ├── FamilyTreeUI.gd      # Family tree UI
│   │   └── menu/
│   │       ├── MainMenu.gd      # Main menu
│   │       └── TitleScreen.gd   # Title screen
│   ├── content/
│   │   └── ContentLoader.gd    # Content pack loader
│   ├── systems/
│   │   ├── SaveSchema.gd        # Save system schema
│   │   ├── Settings.gd          # Settings manager
│   │   ├── SliceLoader.gd       # Vertical slice loader
│   │   └── AutosaveManager.gd  # Autosave system
│   ├── qa/
│   │   ├── RegressionTester.gd  # Regression test suite
│   │   ├── LongRunSimulator.gd  # Long-run crash detection
│   │   ├── DebugVisualizer.gd  # Debug visualizations
│   │   └── FeedbackReporter.gd  # In-game feedback
│   └── dev/
│       ├── DevConsole.gd       # Dev console
│       └── DebugOverlay.gd      # Debug overlay
├── scenes/
│   ├── farm.tscn                # Farm scene
│   └── ui/
│       ├── character_creation.tscn # Character creation UI
│       ├── menu/
│       │   ├── main_menu.tscn   # Main menu UI
│       │   └── title_screen.tscn # Title screen UI
│       └── family_tree.tscn    # Family tree UI
├── tools/
│   ├── sprite_generator.py      # Procedural sprite generator
│   ├── sim/
│   │   └── balance_simulator.py # Balance testing simulator
│   └── requirements.txt         # Python dependencies
├── docs/
│   ├── README.md                # Documentation landing
│   ├── GAME_DESIGN.md           # Design bible
│   ├── LORE_BIBLE.md            # Setting reference
│   ├── SYSTEMS/                 # System documentation
│   ├── PLAYER_GUIDE/            # Player-facing guides
│   ├── TECHNICAL/               # Technical documentation
│   └── AUDIO_VISUAL/            # Art and audio docs
├── .github/
│   └── workflows/
│       └── build.yml            # CI/CD pipeline
├── project.godot                # Godot project configuration
├── Makefile                     # Build automation
├── CHANGELOG.md                 # Version history
├── README.md                    # Project overview
└── LICENSE                      # License text
```

---

## Notable Directories

### `scripts/`

**Purpose**: GDScript game logic

**Organization**: Grouped by system (atmosphere, world, npcs, rpg, ui)

**Pattern**: One class per file, descriptive names

**Example**: `scripts/npcs/NPCSystem.gd` → `NPCSystem` class

---

### `data/`

**Purpose**: JSON configuration files

**Organization**: Grouped by system (npcs, world, rpg, heirlooms)

**Pattern**: One JSON file per entity type

**Example**: `data/npcs/npcs.json` → Array of NPC definitions

---

### `scenes/`

**Purpose**: Godot scene files (.tscn)

**Organization**: Grouped by system (ui, world, npcs)

**Pattern**: One scene per UI/system screen

**Example**: `scenes/ui/menu/main_menu.tscn` → Main menu UI

---

### `assets/`

**Purpose**: Art, audio, and generated assets

**Organization**: Grouped by type (sprites, tiles, ui, sounds)

**Pattern**: Subdirectories for each asset type

**Example**: `assets/sprites/crops/` → Crop sprite images

---

### `tools/`

**Purpose**: Python utilities for development

**Organization**: One script per tool

**Pattern**: Command-line tools, documented in comments

**Example**: `tools/sprite_generator.py` → Generates procedural sprites

---

### `docs/`

**Purpose**: Documentation (this folder)

**Organization**: Grouped by audience (player, technical, systems)

**Pattern**: One markdown file per topic

**Example**: `docs/SYSTEMS/farming_system.md` → Farming system documentation

---

## File Naming Conventions

### Scripts

**Format**: `PascalCase.gd`

**Examples**:
- `GameManager.gd`
- `NPCSystem.gd`
- `CharacterCreation.gd`

---

### Data Files

**Format**: `snake_case.json`

**Examples**:
- `crops.json`
- `world_events.json`
- `rpg_stats.json`

---

### Scenes

**Format**: `snake_case.tscn`

**Examples**:
- `farm.tscn`
- `character_creation.tscn`
- `main_menu.tscn`

---

### Assets

**Format**: `snake_case.png` (or `.ogg`, `.mp3`, etc.)

**Examples**:
- `ironwheat_sprite.png`
- `farm_background.png`
- `title_theme.ogg`

---

## Data File Structure

### Crop Definition

**File**: `data/crops.json`

**Format**: Array of crop objects

```json
[
  {
    "name": "ironwheat",
    "growth_stages": 5,
    "requires": ["iron", "water", "sunlight"],
    "output": ["grain", "metal_scrap"],
    "likes": ["ferro_soil"],
    "hates": ["pure_bio_soil"],
    "biomechanical": true
  }
]
```

---

### NPC Definition

**File**: `data/npcs/npcs.json`

**Format**: Array of NPC objects

```json
[
  {
    "id": "mara_old",
    "name": "Old Mara",
    "faction": "rootbound",
    "age": 78,
    "schedule": {...},
    "opinions": {...},
    "traits": ["wise", "skeptical"]
  }
]
```

---

### World Event Definition

**File**: `data/world/events/world_events.json`

**Format**: Array of event objects

```json
[
  {
    "id": "bandit_attack_brassford",
    "trigger_conditions": {...},
    "effects": {...},
    "rumors": [...]
  }
]
```

---

## Code Organization Patterns

### Singleton Pattern

**GameManager**: Central coordinator (singleton)

**Usage**: `GameManager.instance` accessed globally

**Example**: `GameManager.instance.advance_day()`

---

### Signal-Based Communication

**Pattern**: Systems emit signals, other systems connect

**Example**:
```gdscript
GameManager.day_advanced.connect(_on_day_advanced)
```

---

### Data-Driven Design

**Pattern**: Game logic reads from JSON files

**Example**: Crops defined in JSON, loaded at runtime

**Benefit**: Easy to add content without code changes

---

**Cross-References:**

- [Architecture Overview](architecture_overview.md) • [Modding Guide](modding_guide.md) • [Content Pipelines](content_pipelines.md) • [Save System](save_system.md) • [Game Design](../GAME_DESIGN.md)

