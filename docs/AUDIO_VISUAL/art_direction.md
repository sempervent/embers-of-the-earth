╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — ART DIRECTION         ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"The palette is muted: copper, ash, soot, brass. The style is pixel art: functional, worn, honest. The world is post-apocalyptic steampunk: machines rust, nature reclaims, survivors struggle." — Artist's Manual*

---

## At a Glance

This document describes the art direction for Embers of the Earth: pixel art style, color palettes, tile sizes, UI framing, portrait guidelines, and visual cues for gameplay elements. Written for artists and contributors.

---

## Art Style

### Pixel Art Aesthetic

**Resolution**: 16×16 or 32×32 pixels per tile

**Style**: Functional, worn, honest

**Feel**: Post-apocalyptic steampunk with nature reclamation

**Reference**: Stardew Valley (aesthetic), SteamWorld Dig (tone), Darkwood (atmosphere)

---

## Color Palettes

### Primary Palette

**Copper**: `#CD7F32` — Primary metal, UI accents  
**Ash**: `#696969` — Wasteland, neutral tones  
**Soot**: `#4B4B4B` — Dark shadows, UI backgrounds  
**Brass**: `#B8860B` — Faction colors, UI highlights

### Biome-Specific Palettes

**Ashlands**:
- Gray: `#808080`
- Brown: `#8B7355`
- Muted tones: `#6B6B6B`

**Rust Plains**:
- Copper: `#CD7F32`
- Orange: `#FF8C00`
- Rust: `#8B0000`

**Fungal Groves**:
- Green: `#556B2F`
- Brown: `#6B4423`
- Organic: `#8B7355`

---

## Tile Sizes

### Crop Tiles

**Base Size**: 16×16 pixels

**Growth Stages**: 5-7 stages per crop

**Variation**: Random mutations (rust veins, gear leaves)

**Style**: Pixel art, functional

---

### Soil Tiles

**Base Size**: 16×16 pixels

**Types**: 5 types (ferro_soil, fungal_soil, ash_soil, pure_bio_soil, scrap_heap)

**Visual Cues**: 
- **Ferro-Soil**: Metallic brown, rust particles
- **Pure Bio**: Dark green, organic texture
- **Scrap Heap**: Mixed debris, metallic scraps

**Mood Indicators**: Color shifts (content = green tint, resentful = brown tint, exhausted = gray tint)

---

### Building Tiles

**Base Size**: 32×32 pixels (buildings larger than crops)

**Types**: Boiler, mill, press, etc.

**Style**: Steampunk, functional, worn

**Details**: Rust patches, steam vents, worn edges

---

## UI Framing

### Brass & Cracked Glass Motif

**Primary Frame**: Brass-colored border (copper `#CD7F32`)

**Glass Panels**: Semi-transparent backgrounds with cracked glass texture

**Style**: Industrial, worn, post-apocalyptic

**Reference**: Steampunk UI, Fallout UI (simplified)

---

### UI Elements

**Buttons**: Brass frames, worn texture, hover glow

**Panels**: Cracked glass background, brass borders

**Text**: Readable font, brass highlights on important text

**Icons**: Pixel art, 16×16 or 32×32, functional

---

## Portrait Guidelines

### Procedural Generation

**Base**: Seed-based generation (from traits + faction + age)

**Style**: Pixel art faces, 64×64 or 128×128 pixels

**Elements**:
- Face shape (based on faction/traits)
- Eye color (varies)
- Hair style/color (based on faction)
- Facial hair (if applicable, age-dependent)
- Scars/markings (based on traits/events)

**Colors**: Muted palette (copper, ash, soot)

**Variation**: Random mutations prevent repetition

---

### Portrait Uses

**Marriage Contracts**: Spouse portraits

**Family Tree**: Generation portraits

**Grave Markers**: Deceased portraits

**NPC Dialogue**: NPC portraits

**Wanted Posters**: If player betrays faction (special case)

---

## Visual Cues

### Soil Mood Indicators

**Content**: Green tint overlay

**Neutral**: No tint (default)

**Resentful**: Brown tint overlay

**Tired**: Yellow tint overlay

**Exhausted**: Gray tint overlay

**[FIELD NOTE]**

*Visual mood indicators help players quickly assess soil health. Color shifts are subtle but noticeable.*

---

### Crop Growth Indicators

**Stages**: Visual progression through growth stages

**Sprout**: Tiny green/yellow sprout

**Growing**: Multiple leaves/stalks

**Mature**: Full plant, ready for harvest

**Withered**: Brown, dead (if crop dies)

---

### Resource Indicators

**Food**: Grain icon (golden/yellow)

**Fuel**: Coal/wood icon (dark gray/brown)

**Water**: Droplet icon (blue)

**Metal**: Scrap icon (gray/copper)

**Steam**: Steam cloud icon (white/gray)

---

## Post-Processing Effects

### Dust/Ash Overlays

**Purpose**: Atmospheric depth

**Style**: Subtle particle overlay (dust motes, ash flakes)

**Intensity**: Varies with weather (ashfall = stronger)

**Color**: Gray/brown, semi-transparent

---

### Vignette

**Purpose**: Focus attention, atmospheric framing

**Style**: Dark edges, subtle

**Intensity**: Low (doesn't obscure gameplay)

**Color**: Dark gray/black

---

### Parallax Layers

**Background**: Distant mountains, sky

**Midground**: Settlement buildings, trees

**Foreground**: Player, crops, tiles

**Depth**: 3-4 layers for atmospheric depth

---

## Animation Guidelines

### Crop Growth

**Style**: Frame-by-frame animation

**Frames**: 5-7 frames per growth stage

**Timing**: Smooth transitions, 0.2s per frame

**Looping**: None (crops grow, don't loop)

---

### Weather Effects

**Ashfall**: Falling particles (ash flakes)

**Storms**: Rain particles, lightning flashes

**Heat Waves**: Heat shimmer (subtle distortion)

**Style**: Particle systems, atmospheric

---

### UI Animations

**Hover**: Subtle glow, slight scale increase

**Click**: Brief flash, scale down

**Transitions**: Fade in/out (0.2s)

**Style**: Smooth, responsive, subtle

---

## Style Consistency

### Do's

✓ Use muted palette (copper, ash, soot, brass)  
✓ Maintain pixel art aesthetic (16×16 or 32×32)  
✓ Keep functional, worn, honest style  
✓ Use visual cues for gameplay (soil mood, crop growth)  
✓ Maintain steampunk post-apocalyptic tone

---

### Don'ts

✗ Don't use bright, saturated colors  
✗ Don't break pixel art grid  
✗ Don't overcomplicate UI (keep functional)  
✗ Don't lose atmospheric tone (keep dark, moody)  
✗ Don't ignore gameplay clarity (visual cues must help)

---

**Cross-References:**

- [Procedural Music](procedural_music.md) • [Shaders & FX](shaders_and_fx.md) • [Technical](../TECHNICAL/architecture_overview.md) • [Game Design](../GAME_DESIGN.md)

