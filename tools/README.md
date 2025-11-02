# Embers of the Earth - Sprite Generator Tools

This directory contains Python tools for procedurally generating pixel art sprites for the game.

## Requirements

Install Python dependencies:

```bash
pip install -r requirements.txt
```

Requires:
- Python 3.8+
- Pillow (PIL) >= 10.0.0

## Sprite Generator

The `sprite_generator.py` script generates:

1. **Crop Sprites** - All growth stages with biomechanical mutations
2. **Soil Tiles** - With memory-based variations (cracks, wear)
3. **Character Sprites** - Based on traits, age, and generation

### Usage

Generate all sprites:

```bash
python tools/sprite_generator.py
```

This will:
- Read crop data from `data/crops.json`
- Generate all crop sprites with growth stages
- Generate soil tiles for all soil types
- Create example character sprites
- Save outputs to `assets/generated/`

### Output Structure

```
assets/generated/
├── crops/
│   ├── ironwheat_stage_1.png
│   ├── ironwheat_stage_2.png
│   └── ...
├── tiles/
│   ├── ferro_soil.png
│   ├── ferro_soil_memory_3.png
│   └── ...
└── character_example.png
```

### Customization

Edit `sprite_generator.py` to:
- Adjust color palettes
- Change sprite sizes (default: 32x32)
- Modify mutation styles
- Add new crop types
- Customize biomechanical overlays

### Sprite Generation Features

#### Crop Sprites
- **Base Shapes**: Wheat, root vegetables, beans, moss
- **Growth Stages**: Animated progression through stages
- **Biomechanical Mutations**: 
  - Rust veins
  - Gear leaves
  - Steam pipes
  - Metal joints

#### Soil Tiles
- **Soil Types**: 5 types with distinct colors
- **Memory Effects**: Cracks and wear based on usage
- **Mechanical Elements**: Pipes for ferro_soil

#### Character Sprites
- **Trait-Based**: Mechanical eye, prosthetic limbs, soot stains
- **Age Effects**: Wrinkles and weathering
- **Generation Tracking**: Visual markers per generation

## Integration with Godot

After generating sprites:

1. Place generated sprites in `assets/generated/`
2. Import into Godot (auto-detected)
3. Update sprite references in scenes/scripts

## Future Enhancements

- **AI-Assisted Generation**: Use ML models for more varied sprites
- **Batch Variants**: Generate multiple variants per sprite
- **Animation Frames**: Generate animation sequences
- **Shader Integration**: Generate normal maps and effects

