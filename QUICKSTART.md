# Quick Start Guide - Atmosphere Systems

## Generating Sprites

1. **Install Python dependencies:**
   ```bash
   pip install -r tools/requirements.txt
   ```

2. **Generate all sprites:**
   ```bash
   python tools/sprite_generator.py
   ```

   This creates:
   - Crop sprites (all stages) in `assets/generated/crops/`
   - Soil tiles in `assets/generated/tiles/`
   - Character examples in `assets/generated/`

3. **Import into Godot:**
   - Sprites are automatically detected in `assets/generated/`
   - Godot will import them on next project open

## Running the Game

1. **Open in Godot 4.2+:**
   - File → Open Project → Select `project.godot`

2. **Run the game:**
   - Press F5 or click Play
   - Farm scene loads with all atmosphere systems

3. **Experience the atmosphere:**
   - Weather changes automatically (30-120 second intervals)
   - Music adapts to conditions
   - Journal entries generate as you play
   - Visual effects respond to time of day

## System Integration

All atmosphere systems are automatically initialized when the farm scene loads:

- **Procedural Music** - Adapts to weather, time, player age
- **Ambient Sounds** - Wind, steam, crickets based on conditions
- **Weather System** - Changes with visual and audio effects
- **Visual Effects** - Particles, color grading, lighting
- **Journal System** - Generates entries as you play

## Testing Individual Systems

### Test Music Conditions

```gdscript
# In Godot console or script
var atmosphere = get_tree().get_first_node_in_group("atmosphere")
atmosphere.procedural_music.update_condition("weather", "dust_storm")
```

### Test Weather

```gdscript
atmosphere.weather_system._transition_to_weather(
    WeatherSystem.WeatherType.DUST_STORM,
    0.8,  # intensity
    30.0  # duration
)
```

### View Journal

```gdscript
var entries = atmosphere.journal_system.get_recent_entries(10)
for entry in entries:
    print(entry.text)
```

## Customization

### Adjust Weather Frequency

Edit `scripts/weather/WeatherSystem.gd`:
```gdscript
var next_change_time = randf_range(30.0, 120.0)  # Change range
```

### Modify Music Tempo

Edit `scripts/audio/ProceduralMusic.gd`:
```gdscript
var tempo: float = 60.0  # Change default BPM
```

### Adjust Sprite Generation

Edit `tools/sprite_generator.py`:
- Change color palettes
- Modify sprite sizes (default: 32x32)
- Adjust mutation styles

## Troubleshooting

**No sprites generated:**
- Ensure Pillow is installed: `pip install Pillow`
- Check that `data/crops.json` exists
- Verify Python 3.8+

**Atmosphere systems not loading:**
- Check that `AtmosphereManager` is created in `FarmScene`
- Verify `GameManager` is set as autoload in `project.godot`
- Check console for errors

**No journal entries:**
- Ensure crops are being harvested
- Check that `AtmosphereManager` is initialized
- Verify journal system is connected to signals

**Weather not changing:**
- Weather changes every 30-120 seconds by default
- Check `WeatherSystem._start_weather_cycle()` is called
- Verify weather system is in scene tree

## Next Steps

1. **Add Audio Assets:**
   - Music layers (OGG/WAV files)
   - Ambient sound loops
   - Event sound effects

2. **Create Visual Assets:**
   - Particle textures
   - UI elements (brass frames, gauges)
   - Shader effects

3. **Fine-tune Systems:**
   - Adjust probabilities
   - Modify templates
   - Tune parameters

## Documentation

- **Full Systems**: `docs/atmosphere-systems.md`
- **Implementation Summary**: `ATMOSPHERE_IMPLEMENTATION.md`
- **Sprite Generator**: `tools/README.md`
- **Main README**: `README.md`

---

Enjoy the atmosphere! 🌬️🎵🎨

