╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — PROCEDURAL MUSIC      ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"Music adapts. The soundtrack shifts with entropy. Order brings mechanical drones. Wild brings organic melodies. The machine-god stirs, and the music changes." — Composer's Manual*

---

## At a Glance

This document describes the procedural music system: instruments, Markov progression, mode shifts by time/weather/entropy, layering rules, and side-chain/ducking triggers. Written for audio designers and contributors.

---

## Music System Overview

### Adaptive Soundtrack

**Purpose**: Music reacts to game state (time, weather, entropy, soil mood)

**Style**: Western/Steampunk hybrid, melancholy, atmospheric

**Base**: Procedurally generated, not fixed tracks

**Reference**: Kentucky Route Zero (atmospheric), The Last of Us (adaptive), Fallout (Western)

---

## Instrument Palette

### Primary Instruments

**Steel Guitar**: Melodic lead, Western tone  
**Harmonica**: Melancholic melodies, frontier feel  
**Mechanical Drums**: Steam-punk rhythms, industrial  
**Brass Section**: Faction themes, ceremonial  
**Organ**: Religious/cult themes, atmospheric  
**Strings**: Emotional depth, tension

---

### Instrument Roles

**Melody**: Steel guitar, harmonica  
**Rhythm**: Mechanical drums, bass  
**Harmony**: Strings, brass  
**Atmosphere**: Organ, ambient textures

---

## Mode System

### Base Modes

**Calm**: Ambient, minimal, peaceful  
**Tense**: Increased tension, minor keys  
**Triumph**: Major keys, uplifting (rare)  
**Despair**: Low notes, dissonant (rare)

---

### Mode Shifts

**Triggers**:
- Time of day (morning = calm, evening = tense)
- Weather (clear = calm, storm = tense)
- Entropy (Order >50 = mechanical, Wild >50 = organic)
- Soil mood (content = calm, resentful = tense)
- Events (world events trigger mode shifts)

**Transitions**: Smooth crossfades (2-3 seconds)

---

## Markov Progression

### Musical Phrase Generation

**Method**: Markov chain for note sequences

**States**: Note sequences, chord progressions

**Transitions**: Probabilistic (based on musical rules)

**Variation**: Random but musically coherent

---

### Chord Progressions

**Base Progressions**: I-V-vi-IV (standard), i-iv-V (minor)

**Variations**: Random substitutions (subdominant, dominant)

**Duration**: 4-8 bars per phrase

**Repetition**: Phrases repeat with variation

---

## Entropy-Based Music

### Order Path (Machine)

**Entropy >50**: Mechanical drones, industrial rhythms

**Instruments**: Mechanical drums, brass (steel), organ (machine-god)

**Melody**: Less melodic, more rhythmic

**Harmony**: Dissonant, metallic

**Reference**: Industrial music, steampunk mechanical

---

### Wild Path (Nature)

**Entropy >50**: Organic melodies, natural rhythms

**Instruments**: Steel guitar, harmonica, strings (organic)

**Melody**: More melodic, flowing

**Harmony**: Consonant, natural

**Reference**: Western folk, nature sounds

---

### Balanced (<50 Each)

**Entropy <50**: Balanced mix of both

**Instruments**: All instruments blend

**Melody**: Balanced melody/rhythm

**Harmony**: Mix of dissonant and consonant

---

## Time-Based Variations

### Morning

**Mode**: Calm, hopeful

**Instruments**: Steel guitar (soft), strings (gentle)

**Tempo**: Moderate, peaceful

**Reference**: Dawn, new beginnings

---

### Noon

**Mode**: Neutral, balanced

**Instruments**: Full ensemble

**Tempo**: Standard, work-like

**Reference**: Midday, activity

---

### Evening

**Mode**: Tense, melancholic

**Instruments**: Harmonica (sad), strings (dramatic)

**Tempo**: Slower, contemplative

**Reference**: Sunset, reflection

---

### Night

**Mode**: Dark, atmospheric

**Instruments**: Organ, ambient textures

**Tempo**: Slow, mysterious

**Reference**: Night, uncertainty

---

## Weather-Based Music

### Clear Weather

**Mode**: Calm, peaceful

**Music**: Standard soundtrack

**No Modifiers**: Base music plays

---

### Ashfall

**Mode**: Oppressive, muffled

**Music**: Low-pass filter applied, muffled sounds

**Instruments**: Muted, distant

**Reference**: Oppression, silence

---

### Storms

**Mode**: Tense, dramatic

**Music**: Increased tension, minor keys

**Instruments**: Strings (dramatic), percussion (thunder-like)

**Reference**: Drama, danger

---

### Heat Waves

**Mode**: Uncomfortable, distorted

**Music**: Slight distortion, heat shimmer effect

**Instruments**: Distorted, uncomfortable

**Reference**: Discomfort, heat

---

## Layering Rules

### Base Layer

**Always On**: Ambient textures, minimal

**Volume**: Low (20-30%)

**Purpose**: Atmospheric foundation

---

### Melodic Layer

**Conditional**: Time of day, soil mood, events

**Volume**: Medium (40-60%)

**Purpose**: Melodic content

---

### Rhythmic Layer

**Conditional**: Entropy path, events

**Volume**: Medium (40-60%)

**Purpose**: Rhythm, drive

---

### Harmonic Layer

**Conditional**: Entropy, events, emotional moments

**Volume**: Low to Medium (20-50%)

**Purpose**: Emotional depth

---

## Side-Chain & Ducking

### Dialogue Ducking

**Trigger**: NPC dialogue, journal entries

**Action**: Music volume reduces by 50%

**Purpose**: Dialogue clarity

**Duration**: While dialogue active

---

### Event Ducking

**Trigger**: Major world events

**Action**: Music fades out (2 seconds)

**Purpose**: Event focus

**Recovery**: Music fades back in after event (3 seconds)

---

### UI Ducking

**Trigger**: Menu open, pause

**Action**: Music volume reduces by 30%

**Purpose**: UI clarity

**Duration**: While UI open

---

## Dynamic Music Examples

### Order Entropy >75 (Machine-God Awakening)

**Mode**: Mechanical, industrial, ominous

**Instruments**: Mechanical drums, brass (steel), organ (machine-god worship)

**Melody**: Minimal, rhythmic focus

**Harmony**: Dissonant, metallic, oppressive

**Tempo**: Moderate, mechanical

**Reference**: Industrial worship, machine-god awakening

---

### Wild Entropy >75 (Nature Triumph)

**Mode**: Organic, natural, uplifting

**Instruments**: Steel guitar, harmonica, strings (organic)

**Melody**: Flowing, melodic

**Harmony**: Consonant, natural

**Tempo**: Moderate, natural rhythms

**Reference**: Western folk, nature triumph

---

### Death Sequence

**Mode**: Melancholic, respectful

**Instruments**: Harmonica (sad), strings (dramatic), organ (funeral)

**Melody**: Slow, mournful

**Harmony**: Minor keys, dissonant (grief)

**Tempo**: Slow, respectful

**Reference**: Funeral, mourning

---

### Marriage Sequence

**Mode**: Hopeful, ceremonial

**Instruments**: Brass (ceremonial), strings (uplifting)

**Melody**: Melodic, hopeful

**Harmony**: Major keys, consonant

**Tempo**: Moderate, ceremonial

**Reference**: Celebration, ceremony

---

**Cross-References:**

- [Art Direction](art_direction.md) • [Shaders & FX](shaders_and_fx.md) • [Technical](../TECHNICAL/architecture_overview.md) • [Atmosphere](../SYSTEMS/entropy_and_endings.md)

