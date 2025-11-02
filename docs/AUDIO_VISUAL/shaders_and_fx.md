╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — SHADERS & FX          ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"The world is post-apocalyptic. The visuals reflect that. Dust overlays. Ash particles. Heat shimmer. Rust effects. The shaders tell the story." — Shader Artist's Manual*

---

## At a Glance

This document describes the visual effects and shaders used in Embers of the Earth: dust/ash overlays, vignette, lightning flash rhythm, parallax layers, and post-processing effects. Written for artists and technical contributors.

---

## Post-Processing Effects

### Dust/Ash Overlay

**Purpose**: Atmospheric depth, post-apocalyptic feel

**Style**: Particle overlay (dust motes, ash flakes)

**Intensity**: Varies with weather
- **Clear**: Minimal (10% opacity)
- **Ashfall**: Strong (50% opacity)
- **Storms**: Moderate (30% opacity)

**Color**: Gray/brown (`#808080`, `#8B7355`)

**Animation**: Falling particles (slow, downward drift)

**Shader**: Particle system with alpha blending

---

### Vignette

**Purpose**: Focus attention, atmospheric framing

**Style**: Dark edges, subtle

**Intensity**: Low (15-20% darkening at edges)

**Color**: Dark gray/black (`#1A1A1A`)

**Shape**: Circular, centered

**Purpose**: Doesn't obscure gameplay, subtle framing

**Shader**: Screen-space radial gradient

---

### Heat Shimmer

**Purpose**: Visual discomfort during heat waves

**Style**: Distortion effect (wave-like)

**Intensity**: Low (subtle, doesn't obscure)

**Color**: No color change (just distortion)

**Animation**: Wave-like distortion (slow oscillation)

**Shader**: Screen-space distortion (UV offset)

**Condition**: Only active during heat waves

---

## Weather Effects

### Ashfall Particles

**Purpose**: Visual representation of ash weather

**Style**: Falling ash flakes

**Intensity**: Varies with ashfall severity
- **Light**: Sparse particles (10-20 per screen)
- **Moderate**: Moderate particles (30-50 per screen)
- **Heavy**: Dense particles (50-100 per screen)

**Color**: Gray (`#808080`)

**Size**: Small (2-4 pixels per particle)

**Animation**: Slow downward drift (gravity simulation)

**Shader**: Particle system with gravity

---

### Storm Lightning

**Purpose**: Dramatic effect during storms

**Style**: Bright flash, brief duration

**Rhythm**: Irregular (not synced to music)

**Timing**: Random intervals (5-15 seconds between flashes)

**Color**: White/yellow (`#FFFFFF`, `#FFFF00`)

**Duration**: Brief (0.1-0.3 seconds)

**Shader**: Full-screen flash (additive blend)

**Sound**: Thunder sound effect (delayed, based on distance)

---

### Rain Particles

**Purpose**: Visual representation of rain during storms

**Style**: Falling rain droplets

**Intensity**: Varies with storm severity
- **Light**: Sparse rain (20-40 particles per screen)
- **Moderate**: Moderate rain (40-60 particles per screen)
- **Heavy**: Dense rain (60-100 particles per screen)

**Color**: Blue/gray (`#87CEEB`, `#808080`)

**Size**: Small (1-2 pixels per particle)

**Animation**: Fast downward motion (gravity)

**Shader**: Particle system with gravity

---

## Soil Mood Visual Cues

### Color Tint Overlays

**Content Soil**: Green tint (`#00FF00` at 10% opacity)

**Neutral Soil**: No tint (default)

**Resentful Soil**: Brown tint (`#8B4513` at 15% opacity)

**Tired Soil**: Yellow tint (`#FFFF00` at 10% opacity)

**Exhausted Soil**: Gray tint (`#808080` at 20% opacity)

**Shader**: Screen-space color overlay (multiply blend)

**Purpose**: Quick visual feedback for soil health

---

### Crop Growth Indicators

**Stage Progression**: Visual changes through growth stages

**Sprout**: Tiny sprite (8×8 pixels)

**Growing**: Medium sprite (12×12 pixels)

**Mature**: Full sprite (16×16 pixels)

**Withered**: Brown, dead (if crop dies)

**Shader**: Standard sprite rendering (no special shader)

---

## Parallax Layers

### Background Layer

**Depth**: Far background (scroll speed: 0.1×)

**Content**: Distant mountains, sky

**Purpose**: Atmospheric depth

**Shader**: Standard 2D parallax scrolling

---

### Midground Layer

**Depth**: Midground (scroll speed: 0.5×)

**Content**: Settlement buildings, trees

**Purpose**: Environmental context

**Shader**: Standard 2D parallax scrolling

---

### Foreground Layer

**Depth**: Foreground (scroll speed: 1.0×)

**Content**: Player, crops, tiles

**Purpose**: Gameplay elements

**Shader**: Standard sprite rendering

---

## Rust Effects

### Building Decay

**Purpose**: Visual representation of worn/rusty buildings

**Style**: Rust patches, wear marks

**Intensity**: Varies with building age/condition

**Color**: Rust (`#8B0000`)

**Shader**: Rust texture overlay (screen-space multiply)

**Condition**: Applied to older buildings

---

### Metal Objects

**Purpose**: Rusty metal aesthetic

**Style**: Rust patches on metal objects

**Intensity**: Low (subtle, doesn't obscure)

**Color**: Rust (`#8B0000`)

**Shader**: Rust texture overlay

**Condition**: Applied to metal items (tools, buildings)

---

## UI Effects

### Button Hover

**Effect**: Subtle glow, slight scale increase

**Intensity**: Low (10% scale, 20% glow)

**Duration**: 0.2s transition

**Shader**: Glow shader (outline + additive blend)

---

### Button Click

**Effect**: Brief flash, scale down

**Intensity**: Flash (0.1s), scale (-5%)

**Duration**: 0.2s total

**Shader**: Flash shader (additive blend)

---

### Panel Transitions

**Effect**: Fade in/out

**Duration**: 0.2s

**Shader**: Alpha fade (lerp from 0 to 1)

---

## Performance Considerations

### Particle Limits

**Dust/Ash**: Max 100 particles per screen

**Rain**: Max 100 particles per screen

**Lightning**: 1 flash at a time (no overlap)

**Optimization**: Cull particles outside screen bounds

---

### Shader Complexity

**Simple**: Screen-space overlays (vignette, color tints)

**Medium**: Particle systems (dust, rain)

**Complex**: Distortion effects (heat shimmer)

**Optimization**: Use simple shaders where possible

---

### Parallax Performance

**Layers**: 3-4 layers max

**Optimization**: Reduce layers if performance drops

**Purpose**: Balance visual depth vs performance

---

**Cross-References:**

- [Art Direction](art_direction.md) • [Procedural Music](procedural_music.md) • [Technical](../TECHNICAL/architecture_overview.md) • [Atmosphere](../SYSTEMS/entropy_and_endings.md)

