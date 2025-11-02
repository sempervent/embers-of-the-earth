╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — ARCHITECTURE OVERVIEW  ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"Every system connects. The farm feeds the settlements. The settlements trade with factions. The factions remember your bloodline. The soil remembers your crops. The world is one great machine." — Engineer's Manual*

---

## At a Glance

This document describes the runtime architecture of Embers of the Earth: system components, signal flow, data dependencies, and integration points. Written for developers and contributors.

---

## Runtime Components

### GameManager (Singleton)

**Location**: `scripts/GameManager.gd`

**Responsibility**: Central coordinator for game state

**Manages**:
- Day/year/season advancement
- Save/load state
- Player reference
- System initialization

**Signals**:
- `day_advanced(day)`
- `year_advanced(year)`
- `season_changed(season)`
- `save_requested()`
- `load_completed()`

---

### AtmosphereManager

**Location**: `scripts/atmosphere/AtmosphereManager.gd`

**Responsibility**: Coordinating atmosphere systems (music, weather, visuals, journal)

**Manages**:
- Procedural music system
- Weather system
- Visual effects system
- Journal system

**Signals**:
- `weather_changed(weather_type)`
- `music_mode_changed(mode)`
- `journal_entry_added(entry)`

---

### NPCSystem

**Location**: `scripts/npcs/NPCSystem.gd`

**Responsibility**: NPC management (opinions, memory, schedules)

**Manages**:
- NPC state and opinions
- Memory system
- Daily schedules
- Opinion calculation

**Signals**:
- `npc_opinion_changed(npc_id, target_id, new_opinion)`
- `npc_aged(npc_id, new_age)`

---

### RumorSystem

**Location**: `scripts/world/events/RumorSystem.gd`

**Responsibility**: Rumor generation and propagation

**Manages**:
- Active rumors list
- Rumor lifecycle (birth, propagation, decay)
- Delivery channels (journal, tavern, market, letter, overheard)

**Signals**:
- `new_rumor_available(rumor_text, source, type)`
- `rumor_propagated(rumor_id, to_settlement)`
- `rumor_decayed(rumor_id)`

---

### WorldEventSystem

**Location**: `scripts/world/events/WorldEventSystem.gd`

**Responsibility**: Dynamic world event triggering

**Manages**:
- World event definitions
- Event trigger conditions
- Event effects (settlement changes, faction changes, rumors)

**Signals**:
- `event_triggered(event_id, event_data)`

---

### EntropySystem

**Location**: `scripts/narrative/EntropySystem.gd`

**Responsibility**: Dual-path entropy tracking (Order vs Wild)

**Manages**:
- Order and Wild meters (0-100)
- Milestone tracking (25, 50, 75)
- Ending triggers (75% threshold)

**Signals**:
- `entropy_changed(order, wild)`
- `entropy_milestone_reached(type, threshold)`
- `ending_triggered(ending_type, ending_data)`

---

### LineageSystem

**Location**: `scripts/family/LineageSystem.gd`

**Responsibility**: Generational succession and inheritance

**Manages**:
- Player aging and death
- Heir selection
- Trait inheritance
- Heirloom passing
- Family tree

**Signals**:
- `player_aged(age)`
- `player_died(player_data)`
- `heir_selected(heir_data)`
- `trait_inherited(trait_name, from_parent)`
- `heirloom_passed(heirloom_id, from_generation, to_generation)`

---

### HeirloomSystem

**Location**: `scripts/npcs/HeirloomSystem.gd`

**Responsibility**: Heirloom management (acquisition, loss, inheritance)

**Manages**:
- Owned heirlooms list
- Heirloom effects (stat bonuses, faction access)
- Lost heirlooms tracking

**Signals**:
- `heirloom_acquired(heirloom_id)`
- `heirloom_lost(heirloom_id)`
- `heirloom_passed(heirloom_id, from_generation, to_generation)`

---

### FarmGrid

**Location**: `scripts/FarmGrid.gd`

**Responsibility**: Tile-based farming system

**Manages**:
- 10×10 grid of tiles
- Soil types and memory
- Crop lifecycle (planting, growth, harvest)
- Soil mood calculation

**Signals**:
- `tile_changed(tile)`
- `crop_ready(tile)`
- `soil_mood_changed(tile, old_mood, new_mood)`

---

### ProductionSystem

**Location**: `scripts/buildings/ProductionSystem.gd`

**Responsibility**: Production buildings and recipe queues

**Manages**:
- Building placement
- Recipe queues
- Input/output conversion
- Production timing

**Signals**:
- `building_placed(building_id, position)`
- `recipe_started(building_id, recipe_id)`
- `recipe_completed(building_id, recipe_id, output)`

---

### WorldController

**Location**: `scripts/world/WorldController.gd`

**Responsibility**: Overworld travel and settlement management

**Manages**:
- Regions and settlements
- Travel routing
- Encounter triggering
- Settlement economy

**Signals**:
- `travel_started(from, to, days)`
- `travel_completed(to, days_consumed)`
- `encounter_triggered(encounter_id)`
- `settlement_reached(settlement_id)`

---

### RPGStatsSystem

**Location**: `scripts/rpg/RPGStatsSystem.gd`

**Responsibility**: Generational stat system (Resolve, Mechanica, Soilcraft, Diplomacy, Vigor)

**Manages**:
- Player stats (5 core stats)
- Stat progression (action-based, no XP bars)
- Stat inheritance (parent to child)
- Progression milestones

**Signals**:
- `stat_changed(stat_name, new_value)`
- `skill_milestone_reached(stat_name, milestone)`

---

### TitleSystem

**Location**: `scripts/rpg/TitleSystem.gd`

**Responsibility**: Earned titles and their effects

**Manages**:
- Earned titles list
- Title requirements checking
- Title effects (stat bonuses, faction opinions)

**Signals**:
- `title_earned(title_id, title_name)`
- `title_lost(title_id)`

---

## Signal Flow

### Day Advancement

```
GameManager.day_advanced
  → FarmGrid._on_day_advanced (crop growth)
  → ProductionSystem._on_day_advanced (recipe progress)
  → NPCSystem._on_day_advanced (schedule updates)
  → RumorSystem._on_day_advanced (rumor decay)
  → WorldEventSystem._on_day_advanced (event checks)
  → AtmosphereManager._on_day_advanced (weather/music updates)
```

---

### Year Advancement

```
GameManager.year_advanced
  → Player._on_year_advanced (aging, death check)
  → NPCSystem._on_year_advanced (NPC aging)
  → EntropySystem._on_year_advanced (entropy milestones)
```

---

### Event Triggering

```
WorldEventSystem.event_triggered
  → RumorSystem._on_world_event_triggered (rumor generation)
  → NPCSystem._on_world_event_triggered (opinion changes)
  → SettlementController._on_world_event_triggered (economy changes)
```

---

### Death & Succession

```
Player._die
  → LineageSystem._on_player_died (heir selection)
  → HeirloomSystem._on_player_died (heirloom passing)
  → RPGStatsSystem._on_player_died (stat inheritance)
```

---

## Data Dependencies

### JSON Data Files

**Location**: `data/` directory

**Types**:
- Crops: `data/crops.json`
- NPCs: `data/npcs/npcs.json`
- Events: `data/world/events/world_events.json`
- Heirlooms: `data/heirlooms/heirlooms.json`
- Settlements: `data/world/settlements.json`
- Factions: `data/factions.json`

**Loader**: `DataLoader` class (loads JSON files on demand)

---

### Save System

**Location**: `scripts/systems/SaveSchema.gd`

**Format**: Versioned JSON schema

**Structure**:
- Schema version
- Game state (year, day, season)
- Player state (name, age, stats, traits, heirlooms)
- Farm grid state (tiles, crops, buildings)
- NPC state (opinions, memory)
- Entropy state (order, wild, history)
- Family tree (generations, lineage)

---

## Integration Points

### Atmosphere ↔ Gameplay

**Weather** → Farming (crop damage, growth speed)  
**Music** → Entropy (mode shifts by Order/Wild)  
**Journal** → NPCs (quotes, rumors, events)

---

### Systems ↔ Player

**Farming** → Resources → Trade → Marriages  
**NPCs** → Reputation → Prices → Contracts  
**Entropy** → Choices → Endings → Epilogue

---

### Data ↔ Systems

**JSON** → DataLoader → Systems → Game State  
**Game State** → SaveSchema → JSON → Persistence

---

## System Initialization Order

1. **GameManager** (singleton initialization)
2. **DataLoader** (load JSON files)
3. **AtmosphereManager** (initialize audio/visual systems)
4. **FarmGrid** (initialize tiles)
5. **Player** (create initial character)
6. **NPCSystem** (load NPCs, calculate opinions)
7. **RumorSystem** (initialize rumor list)
8. **WorldEventSystem** (load event definitions)
9. **EntropySystem** (initialize meters)
10. **LineageSystem** (initialize family tree)
11. **ProductionSystem** (initialize buildings)
12. **WorldController** (initialize settlements)

---

**Cross-References:**

- [File Structure](file_structure.md) • [Modding Guide](modding_guide.md) • [Save System](save_system.md) • [Content Pipelines](content_pipelines.md) • [Game Design](../GAME_DESIGN.md)

