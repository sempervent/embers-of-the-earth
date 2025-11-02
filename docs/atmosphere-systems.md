# Atmosphere Systems Documentation

## Overview

The atmosphere systems create the sensory experience of Embers of the Earth:

- **Procedural Music** - Adaptive Western/Steampunk soundtrack
- **Ambient Sounds** - Environmental audio layers
- **Weather System** - Dynamic weather with visual/audio effects
- **Visual Effects** - Particles, shaders, parallax, post-processing
- **Journal System** - Procedural storytelling

## Architecture

All atmosphere systems are managed by `AtmosphereManager`, which:

1. Initializes all subsystems
2. Connects signals between systems
3. Coordinates updates with game state
4. Handles cross-system events

## Procedural Music System

### `ProceduralMusic.gd`

Generates adaptive music using:
- **Markov Chain Chord Progressions** - Western minor pentatonic, Dorian modes
- **Dynamic Layering** - Instruments add/remove based on conditions
- **Conditional Changes** - Music adapts to gameplay state

### Music Conditions

| Condition | Effect |
|-----------|--------|
| Morning calm | Sparse banjo + ticking valves |
| Dust storm | Droning harmonium + low brass |
| Player aging | Cracked music box, slowed tempo |
| Death | Wind over empty strings, heartbeat stops |

### Instrument Layers

- **Banjo** - Calm, sparse plucks
- **Harmonica** - Dusty, breathy
- **Percussion** - Mechanical ticking (valves, gears)
- **Violin** - Bowed saw, creaky strings
- **Steel Guitar** - Reverb over ruins
- **Harmonium** - Wind-up music box
- **Brass** - Low, droning

### Chord Progression Generation

Uses Markov chains with transitions:
- `i` → `iv`, `v`, `i`, `vi` (Minor tonic)
- `iv` → `i`, `v`, `vi` (Subdominant)
- `v` → `i`, `vi`, `iv` (Dominant)
- `vi` → `iv`, `v`, `i` (Relative major)

## Ambient Sound Manager

### `AmbientSoundManager.gd`

Manages continuous environmental sounds:

### Sound Categories

- **Ambient Loops**: Wind, steam, machinery, crickets, distant pipes
- **Event Sounds**: Valve clicks, gear clicks, heartbeat, soil pulse
- **Spatial Sounds**: Position-based audio

### Dynamic Mixing

Sounds layer based on:
- **Time of Day**: Crickets at night
- **Weather**: Wind strength affects volume
- **Steam Activity**: Hissing when active
- **Machinery**: Running equipment sounds

## Weather System

### `WeatherSystem.gd`

Procedural weather with visual and audio effects.

### Weather Types

| Type | Visual Effect | Audio Effect | Duration |
|------|---------------|--------------|----------|
| Clear | None | Baseline | - |
| Ash Fall | Dark particles, gentle fall | Quiet, muffled | 20-60s |
| Dust Storm | Brown dust clouds, high intensity | Strong wind, harmonium | 30-90s |
| Static Storm | Lightning flashes, sparks | Static cracks | 40-80s |
| Steam Fog | White steam rising | Hissing, mechanical | 30-60s |
| Dry Wind | Crop bending, UI flicker | Wind sounds | 25-70s |

### Weather Parameters

- **Intensity**: 0.0 to 1.0 (affects particle count, volume)
- **Duration**: Random 20-120 seconds
- **Wind Direction**: Degrees (affects particle drift)
- **Wind Speed**: 0.0 to 1.0 (affects UI flicker, crop bend)

### Integration

Weather affects:
- Music (dust storm → tense music)
- Ambient sounds (wind volume)
- Visual effects (particles, lighting)
- Crop growth (future: weather damage)

## Visual Effects System

### `VisualEffects.gd`

Handles all visual atmosphere:

### Effects

- **Post-Processing**: 
  - Canvas modulate (color grading)
  - Vignette (dark edges)
  - Dust overlay (color tint)

- **Particles**:
  - Steam vents (from farm tiles)
  - Ash clouds (parallax layer)
  - Pollen (parallax layer)

- **Lighting**:
  - Light rays (dawn through roofs)
  - Lightning flashes (static storms)
  - UI lamp flicker (wind effect)

- **Crop Effects**:
  - Wind bending (shader-based)
  - Growth animations (future)

### Time of Day Modulation

Canvas modulate adjusts by time:
- **Morning**: Warm (1.0, 0.95, 0.9)
- **Noon**: Bright (1.0, 1.0, 0.95)
- **Evening**: Golden (0.95, 0.85, 0.8)
- **Night**: Cool (0.6, 0.65, 0.7)

## Journal System

### `JournalSystem.gd`

Procedurally generates journal entries based on gameplay:

### Entry Types

- **First Harvest**: Crop planted, soil mood
- **Marriage**: Spouse, faction, offerings
- **Death**: Age, cause, successor
- **Weather**: Weather type, crop status
- **Soil Memory**: Years used, mood, position
- **Machine Events**: Awakening, stirring
- **First Child**: Birth, bloodline continuation
- **Yearly Summary**: Year end, harvest count, age

### Templates

Each entry type has multiple templates:
```gdscript
"first_harvest": [
    "The first {crop} of this generation. The soil whispers {mood}. —{name}",
    "Harvested {crop} today. The earth remembers {last_crop}. —{name}",
    ...
]
```

Templates are filled with game data procedurally.

### Generation Tracking

- Tracks generation and year for each entry
- Can filter by generation or year
- Stores timestamps for chronological order

## Integration Guide

### Adding to Scene

```gdscript
# In FarmScene.gd
var atmosphere_manager: AtmosphereManager

func _ready():
    atmosphere_manager = AtmosphereManager.new()
    add_child(atmosphere_manager)
```

### Triggering Events

```gdscript
# Player death
atmosphere_manager.on_player_died(successor_data)

# Machine awakening
atmosphere_manager.trigger_machine_event()

# Crop growth
atmosphere_manager.trigger_crop_growth_event()
```

### Connecting Signals

```gdscript
atmosphere_manager.journal_system.journal_entry_added.connect(
    _on_journal_entry_added
)
```

## Future Enhancements

- **MIDI Synthesis**: Actual procedural MIDI generation
- **Audio Streams**: Load real audio files for instruments
- **Advanced Shaders**: Dust, fog, light scattering
- **AI-Generated Journal**: LLM integration for more varied entries
- **Weather Persistence**: Weather affects next day
- **Sound Design**: Real audio assets for all events

## Configuration

All systems can be configured via:
- Data files (JSON)
- Script parameters
- Godot project settings

Modify constants in each script to adjust:
- Tempo, chord progressions (music)
- Volume levels, fade times (sound)
- Weather probabilities, durations (weather)
- Particle counts, colors (visual)

