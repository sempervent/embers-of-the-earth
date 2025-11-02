# Embers of the Earth - Development Roadmap

## Current Status: **All Systems Complete** ✅

The game engine is fully implemented. Now we focus on polish, content, and making it beautiful.

---

## 🎯 Phase 1: Stability & QA (Current Priority)

### Goal: Make existing systems unbreakable

**Timeline**: 1-2 weeks

### Tasks

#### 1.1 Automated Testing
- ✅ `RegressionTester.gd` - Core system tests
- ✅ `LongRunSimulator.gd` - 100+ year simulations
- ⚠️ **TODO**: Add UI test integration
- ⚠️ **TODO**: Add save/load stress tests

#### 1.2 Debug Visualizations
- ✅ `DebugVisualizer.gd` - Resource flow, entropy, NPC opinions
- ⚠️ **TODO**: Implement actual drawing code
- ⚠️ **TODO**: Add toggle hotkeys

#### 1.3 Crash Detection
- ✅ Basic crash checking in long sim
- ⚠️ **TODO**: Add crash log file generation
- ⚠️ **TODO**: Add stack trace capture
- ⚠️ **TODO**: Add crash reporter UI

#### 1.4 Bug Reporter
- ✅ `FeedbackReporter.gd` - In-game feedback system
- ⚠️ **TODO**: Add screenshot capability
- ⚠️ **TODO**: Add crash log attachment
- ⚠️ **TODO**: Add seed replay file

### Deliverables
- ✅ Regression test suite
- ✅ Long-run simulator (100+ years)
- ✅ Debug visualization framework
- ⚠️ Crash detection and logging
- ⚠️ Bug reporter with screenshots

### Acceptance Criteria
- [ ] All regression tests pass
- [ ] Long simulation runs 100+ years without crashes
- [ ] Debug visualizations show resource flow
- [ ] Crash logs capture all errors
- [ ] Feedback system exports complete reports

---

## 🎯 Phase 2: Content Expansion

### Goal: Expand world content by 3x

**Timeline**: 2-3 weeks

### Content Targets

#### 2.1 Crops (4 → 12)
- ✅ Template created
- ⚠️ **TODO**: Design 8 new biomechanical crops
- ⚠️ **TODO**: Create sprite generation data
- ⚠️ **TODO**: Add lore for each crop

**New Crops Needed:**
- Steamroot (existing)
- Cogbean (existing)
- Rustmoss (existing)
- **NEW**: Copperwheat, Gearvine, Boltroot, Steambean, Rustleaf, Ironroot, Machine-Moss, Cogwheat

#### 2.2 NPCs (6 → 20)
- ✅ Template created
- ⚠️ **TODO**: Design 14 new NPCs across settlements
- ⚠️ **TODO**: Write quotes for each opinion level
- ⚠️ **TODO**: Create memory events
- ⚠️ **TODO**: Add relationships between NPCs

**NPC Distribution:**
- Brassford: 5 NPCs (currently 3)
- Ash Caravan: 4 NPCs (currently 1)
- Rust Gate: 4 NPCs (currently 1)
- Root Keepers: 4 NPCs (currently 1)
- New Settlement: 3 NPCs

#### 2.3 Events (6 → 15)
- ✅ Template created
- ⚠️ **TODO**: Design 9 new world events
- ⚠️ **TODO**: Create unique effects and rumors
- ⚠️ **TODO**: Add event chains (event A triggers event B)

**New Events Needed:**
- **NEW**: Plague Outbreak, Drought Miracle, Mech-God Tremor, Faction War, Bandit Empire, Trade Route Opens, Old World Cache Found, Machine Beast Tamed, Nature Prophet Emerges

#### 2.4 Heirlooms (6 → 12)
- ⚠️ **TODO**: Design 6 new heirlooms
- ⚠️ **TODO**: Create unique effects
- ⚠️ **TODO**: Write lore for each

**New Heirlooms Needed:**
- **NEW**: Grandmother's Journal, Father's Wrench, Stolen Faction Banner, Machine-God Fragment, Root Keeper's Pledge, Exiled King's Crown

### Deliverables
- ✅ Content templates for all types
- ⚠️ 12 crops with sprites
- ⚠️ 20 NPCs with schedules and quotes
- ⚠️ 15 world events with unique effects
- ⚠️ 12 heirlooms with lore

### Acceptance Criteria
- [ ] All content loads from JSON
- [ ] New crops appear in game
- [ ] NPCs have unique personalities
- [ ] Events trigger correctly
- [ ] Heirlooms have meaningful effects

---

## 🎯 Phase 3: Visual & Audio Identity

### Goal: Lock in iconic art style

**Timeline**: 3-4 weeks

### 3.1 Pixel Art Style
- ✅ Sprite generator framework
- ⚠️ **TODO**: Finalize palette (2-3 tones per biome)
- ⚠️ **TODO**: Create base sprite set
- ⚠️ **TODO**: Implement procedural overlays

**Biomes:**
- Ashlands: Gray, brown, muted
- Rust Plains: Copper, orange, rust
- Fungal Groves: Green, brown, organic

#### 3.2 Portrait System
- ✅ Framework ready
- ⚠️ **TODO**: Create procedural portrait generator
- ⚠️ **TODO**: Generate faces from traits + faction + age
- ⚠️ **TODO**: Use in marriage contracts, family tree, NPCs

#### 3.3 Soundtrack
- ✅ Procedural music framework
- ⚠️ **TODO**: Create 10 key themes:
  - Travel Theme
  - Mourning Theme
  - Wedding Theme
  - Machine Worship
  - Dawn Theme
  - Famine Theme
  - Harvest Theme
  - Death Theme
  - Order Ending Theme
  - Wild Ending Theme

#### 3.4 Dynamic Audio
- ⚠️ **TODO**: Implement soil mood → music modifier
- ⚠️ **TODO**: Family shame → audio filter
- ⚠️ **TODO**: Add side-chain ducking

#### 3.5 Shaders & Post-Processing
- ⚠️ **TODO**: Create palette LUT shader
- ⚠️ **TODO**: Implement wind sway for crops
- ⚠️ **TODO**: Add CRT micro-scanline toggle
- ⚠️ **TODO**: Create dust overlay shader

### Deliverables
- ⚠️ Finalized art style guide
- ⚠️ Procedural portrait system
- ⚠️ 10 soundtrack themes
- ⚠️ Dynamic audio modifiers
- ⚠️ Post-processing shaders

### Acceptance Criteria
- [ ] All sprites follow style guide
- [ ] Portraits generate correctly
- [ ] Music adapts to game state
- [ ] Shaders enhance atmosphere
- [ ] Performance acceptable (60 FPS)

---

## 🎯 Phase 4: Endings & Emotional Payoff

### Goal: Make finishing feel sacred/tragic/triumphant

**Timeline**: 1-2 weeks

### 4.1 Ending System
- ✅ `EndingSystem.gd` - Ending management
- ⚠️ **TODO**: Create ending scenes
- ⚠️ **TODO**: Generate monologues from choices
- ⚠️ **TODO**: Add ending-specific music

### 4.2 Epilogue
- ✅ Epilogue generation framework
- ⚠️ **TODO**: Visual family tree with graves
- ⚠️ **TODO**: Missing heirlooms display
- ⚠️ **TODO**: Final NPC memories
- ⚠️ **TODO**: Legacy rumors

### 4.3 Ending Poems
- ✅ Poem generation system
- ⚠️ **TODO**: Expand poem templates
- ⚠️ **TODO**: Add visual poetry display

### 4.4 "Continue as NPC" Mode
- ⚠️ **TODO**: Roguelite unlock system
- ⚠️ **TODO**: Player becomes wandering NPC
- ⚠️ **TODO**: New players can encounter your NPC

### Deliverables
- ✅ Ending system framework
- ⚠️ 4 ending sequences (Order, Wild, Extinction, Wandering)
- ⚠️ Visual epilogue screen
- ⚠️ Procedural ending poems
- ⚠️ NPC mode unlock

### Acceptance Criteria
- [ ] Endings trigger correctly
- [ ] Epilogue shows complete legacy
- [ ] Poems are emotionally resonant
- [ ] NPC mode unlocks after ending
- [ ] Players feel closure

---

## 🎯 Phase 5: Playtesting & Feedback Loop

### Goal: Get game into human hands

**Timeline**: Ongoing

### 5.1 Beta Build
- ⚠️ **TODO**: Export vertical slice build
- ⚠️ **TODO**: Create Steam-style beta package
- ⚠️ **TODO**: Add "Beta Version" watermark

### 5.2 Feedback System
- ✅ `FeedbackReporter.gd` - In-game feedback
- ⚠️ **TODO**: Add screenshot capability
- ⚠️ **TODO**: Export feedback to JSON
- ⚠️ **TODO**: Create feedback aggregation tool

### 5.3 Playtest Guide
- ✅ Created in this file
- ⚠️ **TODO**: Create external playtest document
- ⚠️ **TODO**: Add specific questions for testers
- ⚠️ **TODO**: Create bug report template

### 5.4 Crash Logging
- ⚠️ **TODO**: Capture all crashes to file
- ⚠️ **TODO**: Include seed and state
- ⚠️ **TODO**: Create replay system

### Deliverables
- ⚠️ Beta build package
- ⚠️ In-game feedback system (complete)
- ⚠️ Playtest guide document
- ⚠️ Crash logging system
- ⚠️ Feedback aggregation reports

### Acceptance Criteria
- [ ] Beta build exports successfully
- [ ] Feedback system captures all data
- [ ] Playtest guide helps testers
- [ ] Crash logs include full context
- [ ] Feedback can be aggregated

---

## 📊 Content Expansion Checklist

### Crops (4 → 12)
- [ ] Steelwheat
- [ ] Copperwheat
- [ ] Gearvine
- [ ] Boltroot
- [ ] Steambean
- [ ] Rustleaf
- [ ] Ironroot
- [ ] Machine-Moss
- [ ] Cogwheat

### NPCs (6 → 20)
- [ ] 5 NPCs at Brassford
- [ ] 4 NPCs at Ash Caravan
- [ ] 4 NPCs at Rust Gate
- [ ] 4 NPCs at Root Keepers
- [ ] 3 NPCs at New Settlement

### Events (6 → 15)
- [ ] Plague Outbreak
- [ ] Drought Miracle
- [ ] Mech-God Tremor
- [ ] Faction War
- [ ] Bandit Empire
- [ ] Trade Route Opens
- [ ] Old World Cache Found
- [ ] Machine Beast Tamed
- [ ] Nature Prophet Emerges

### Heirlooms (6 → 12)
- [ ] Grandmother's Journal
- [ ] Father's Wrench
- [ ] Stolen Faction Banner
- [ ] Machine-God Fragment
- [ ] Root Keeper's Pledge
- [ ] Exiled King's Crown

---

## 🎯 Critical Path

### Must-Have Before Public Beta

1. ✅ **All Systems Functional**
2. ⚠️ **Stability** - No crashes in 100-year sim
3. ⚠️ **Content** - 12 crops, 20 NPCs, 15 events
4. ⚠️ **Visual Identity** - Art style locked, portraits working
5. ⚠️ **Endings** - All 4 endings functional with epilogue
6. ⚠️ **Bug Reporter** - Complete feedback system
7. ⚠️ **Main Menu** - Title screen, save slots, settings

### Nice-to-Have Before Launch

1. ⚠️ Procedural portrait system polished
2. ⚠️ 10 soundtrack themes complete
3. ⚠️ All shaders implemented
4. ⚠️ "Continue as NPC" mode
5. ⚠️ Developer commentary mode

---

## 📅 Estimated Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| Phase 1: Stability & QA | 1-2 weeks | ✅ Framework ready |
| Phase 2: Content Expansion | 2-3 weeks | ⚠️ Templates ready |
| Phase 3: Visual & Audio | 3-4 weeks | ⚠️ Frameworks ready |
| Phase 4: Endings | 1-2 weeks | ✅ Framework ready |
| Phase 5: Playtesting | Ongoing | ⚠️ In progress |

**Total**: 7-11 weeks to beta-ready state

---

## 🎯 Success Metrics

### Before Beta
- [ ] Zero crashes in 100-year simulation
- [ ] All systems tested and stable
- [ ] Content expanded 3x (crops, NPCs, events)
- [ ] Visual identity complete
- [ ] All endings functional
- [ ] Feedback system operational

### Before Launch
- [ ] 100+ hours of playtesting
- [ ] <5% crash rate
- [ ] Positive feedback from testers
- [ ] All critical bugs fixed
- [ ] Documentation complete

---

**Status**: Ready for content expansion and polish phase

