╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — DOCUMENTATION        ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"The earth remembers. Every seed planted, every harvest taken. The machine-god sleeps beneath, but the soil holds our history." — First Farmer's Letter*

---

## At a Glance

**Embers of the Earth** is a post-apocalyptic steampunk farming RPG with generational bloodlines, soil memory, faction diplomacy, and dual-path endings. This documentation serves as both a field manual for players and a technical reference for contributors.

### Project Pillars

- **Soil Remembers**: Every tile tracks its history. Monoculture abuse yields resentment; crop rotation fosters content soil. The land learns your patterns.
- **Bloodline Continuity**: When you die, control passes to an heir. Traits, heirlooms, and shame echo across generations.
- **Entropy Paths**: Two futures war beneath the earth. Order (machines, steam, steel) or Wild (nature, roots, pure soil). Your choices push the meter.
- **Barter Diplomacy**: Marriages seal faction alliances. Reputation affects prices. NPCs remember broken contracts for generations.

---

## Documentation Structure

### For Players

- **[Getting Started](PLAYER_GUIDE/getting_started.md)** — Your first seven days
- **[Survival Guide](PLAYER_GUIDE/survival_guide.md)** — Weather, injuries, winter prep
- **[Lineage & Heirs](PLAYER_GUIDE/lineage_and_heirs.md)** — Raising children, inheritance
- **[Travel & Trade](PLAYER_GUIDE/travel_and_trade.md)** — Routes, encounters, settlements
- **[Marriage & Factions](PLAYER_GUIDE/marriage_and_factions.md)** — Contracts, obligations, reputation

### For Designers & Developers

- **[Game Design](GAME_DESIGN.md)** — Core loop, pillars, progression arcs
- **[Lore Bible](LORE_BIBLE.md)** — Setting, factions, heirlooms, timeline
- **[Systems Documentation](SYSTEMS/)** — Technical deep-dives:
  - [Farming System](SYSTEMS/farming_system.md)
  - [Lineage System](SYSTEMS/lineage_system.md)
  - [NPC & Rumor System](SYSTEMS/npc_and_rumor_system.md)
  - [Entropy & Endings](SYSTEMS/entropy_and_endings.md)
  - [Overworld & Travel](SYSTEMS/overworld_and_travel.md)
  - [Production & Economy](SYSTEMS/production_and_economy.md)
- **[Technical Documentation](TECHNICAL/)** — Architecture, modding, pipelines:
  - [Architecture Overview](TECHNICAL/architecture_overview.md)
  - [File Structure](TECHNICAL/file_structure.md)
  - [Modding Guide](TECHNICAL/modding_guide.md)
  - [Content Pipelines](TECHNICAL/content_pipelines.md)
  - [Save System](TECHNICAL/save_system.md)

### For Artists & Audio

- **[Art Direction](AUDIO_VISUAL/art_direction.md)** — Palette, style, guidelines
- **[Procedural Music](AUDIO_VISUAL/procedural_music.md)** — Soundtrack system
- **[Shaders & FX](AUDIO_VISUAL/shaders_and_fx.md)** — Visual effects

---

## What's in This Repository

```
embers-of-the-earth/
├── scripts/          # GDScript game logic (50+ files)
├── scenes/           # Godot scene files
├── data/             # JSON configuration (crops, NPCs, events)
├── assets/           # Sprites, sounds, shaders
├── tools/            # Python utilities (sprite gen, balance sim)
├── docs/             # This documentation set
├── project.godot     # Godot project configuration
└── README.md         # Project overview
```

### Core Systems Implemented

- ✅ Farming with soil memory and biomechanical crops
- ✅ Generational bloodline system with inheritance
- ✅ NPC relationships and rumor propagation
- ✅ Dynamic world events and faction diplomacy
- ✅ Production buildings with recipe queues
- ✅ Dual-path entropy system (Order vs Wild)
- ✅ Overworld travel with encounters and hazards
- ✅ Procedural music and weather systems
- ✅ Journal system with procedural entries
- ✅ Character creation and RPG progression

---

## Recommended Reading Path

### New Players
1. **[Getting Started](PLAYER_GUIDE/getting_started.md)** — First session guide
2. **[Survival Guide](PLAYER_GUIDE/survival_guide.md)** — Essential mechanics
3. **[Lore Bible](LORE_BIBLE.md)** — Understand the world

### Returning Players
1. **[Lineage & Heirs](PLAYER_GUIDE/lineage_and_heirs.md)** — Generational mechanics
2. **[Travel & Trade](PLAYER_GUIDE/travel_and_trade.md)** — Settlement strategies
3. **[Marriage & Factions](PLAYER_GUIDE/marriage_and_factions.md)** — Alliance building

### Contributors & Modders
1. **[Game Design](GAME_DESIGN.md)** — Design philosophy
2. **[Modding Guide](TECHNICAL/modding_guide.md)** — How to add content
3. **[Content Pipelines](TECHNICAL/content_pipelines.md)** — Data formats
4. **[Systems Documentation](SYSTEMS/)** — Technical reference

---

## Support & Feedback

### In-Game Feedback

Press **ESC** → "Send Feedback" to report bugs, suggest features, or share your experience. The feedback system captures screenshots and game state automatically.

### Playtesting

See `PLAYTEST_GUIDE.md` (root) for playtesting protocols and feedback templates.

### Issues

Report bugs or request features via GitHub Issues (if applicable).

---

## Versioning & Changelog

Release notes and version history are maintained in [`CHANGELOG.md`](../CHANGELOG.md) at the repository root.

Current version: **v0.1.0 (Early Access)**

---

## Quick Links

**Player Resources:**
- [Getting Started](PLAYER_GUIDE/getting_started.md)
- [Survival Guide](PLAYER_GUIDE/survival_guide.md)
- [Lore Bible](LORE_BIBLE.md)

**Technical Resources:**
- [Architecture Overview](TECHNICAL/architecture_overview.md)
- [Modding Guide](TECHNICAL/modding_guide.md)
- [Systems Documentation](SYSTEMS/)

**Design Resources:**
- [Game Design](GAME_DESIGN.md)
- [Art Direction](AUDIO_VISUAL/art_direction.md)
- [Procedural Music](AUDIO_VISUAL/procedural_music.md)

---

**Cross-References:**

- [Game Design](GAME_DESIGN.md) • [Lore Bible](LORE_BIBLE.md) • [Systems](../SYSTEMS/farming_system.md) • [Player Guide](PLAYER_GUIDE/getting_started.md) • [Technical](TECHNICAL/architecture_overview.md)

