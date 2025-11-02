╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — GAME DESIGN          ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"Your bloodline is your legacy. Your choices echo through generations." — First Farmer*

---

## At a Glance

**Embers of the Earth** is a post-apocalyptic steampunk farming RPG where players manage a bloodline across generations. The core experience centers on soil memory, faction diplomacy, dual-path entropy, and legacy building.

### Core Loop

1. **Tend the Farm** — Till soil, plant crops, harvest yields
2. **Manage Resources** — Food, fuel, metal, steam energy
3. **Travel & Trade** — Visit settlements, negotiate deals
4. **Build Alliances** — Arrange marriages, fulfill obligations
5. **Age & Die** — Pass control to an heir
6. **Shape the Future** — Push entropy toward Order or Wild

---

## Design Pillars

### 1. Soil Remembers

Every tile tracks its history: crops planted, years used, mood (content → resentful → exhausted). Players must manage soil memory or face declining yields. Crop rotation, fertilization, and respecting soil preferences prevent degradation.

**Player Impact**: Farming decisions have long-term consequences. Neglect soil health, and the land rebels.

### 2. Bloodline Continuity

When the player character dies, control passes to a child. Traits, heirlooms, and reputation echo across generations. NPCs remember your grandfather's broken contract. Shame persists.

**Player Impact**: Every generation must live with past choices. Redemption is possible but costly.

### 3. Entropy Paths

Two futures war beneath the earth: **Order** (machines, steam, steel) and **Wild** (nature, roots, pure biology). Player actions push the meter. Reach 75% on either path → ending triggers.

**Player Impact**: Farming biomechanical crops pushes Order. Favoring nature pushes Wild. The endgame depends on your path.

### 4. Barter Diplomacy

Marriages seal faction alliances. Contracts include dowries, obligations (tribute, apprenticeship), and benefits (tech, seeds, protection). Break a contract → shame echoes. Honor obligations → reputation grows.

**Player Impact**: Diplomacy is permanent. Choose factions carefully.

---

## Anti-Pillars (What This Game Is Not)

- ❌ **Not a grindfest** — Story and consequences drive progression, not XP bars
- ❌ **Not a city builder** — Focus is on farming and lineage, not base expansion
- ❌ **Not a combat game** — Hazards are choice-based, not action combat
- ❌ **Not a peaceful sim** — The world is hostile; survival requires hard choices

---

## Progression Arcs

### Arc 1: The First Farmer (Days 1–30)

**Goal**: Establish the farm, learn systems, survive first winter

**Activities**:
- Plant first crops
- Learn soil types and memory
- Visit nearest settlement
- Complete first harvest

**Milestones**: First harvest, first trade, first journal entry

### Arc 2: Foundation (Days 31–120)

**Goal**: Build production capacity, establish faction relationships

**Activities**:
- Place first building (boiler, mill)
- Arrange first marriage
- Expand crop variety
- Manage soil memory actively

**Milestones**: First marriage, first building, faction reputation established

### Arc 3: Expansion (Years 2–5)

**Goal**: Build legacy, pass to second generation

**Activities**:
- Multiple marriages
- Production chains (input → output)
- Long-distance trade
- Entropy choices become visible

**Milestones**: Second generation, multiple heirlooms, entropy milestones

### Arc 4: The Path Divides (Years 6–10)

**Goal**: Commit to Order or Wild, shape the ending

**Activities**:
- Build advanced buildings (machine path) or nurture pure soil (wild path)
- Major faction decisions
- Entropy events trigger
- Prepare for ending

**Milestones**: Entropy >50, major events, third generation

### Arc 5: Legacy (Years 11+)

**Goal**: Reach ending, see the consequences

**Activities**:
- Final entropy push (>75%)
- Complete family obligations
- Witness ending (Order/Wild/Extinction)
- Reflect on legacy

**Milestones**: Ending triggered, epilogue, final family tree

---

## Failure States

### Hard Failures

**Extinction** — Player dies with no heirs. Game ends. Epilogue shows abandoned farm.

**Unwinnable State** — No food, no fuel, no crops, can't travel. Farm starves. Game ends.

### Soft Failures

**Lost Heirlooms** — Bandits steal heirloom seeds. Family history erased. Stat bonuses lost.

**Broken Contracts** — Faction abandons alliance. Reputation crashes. NPCs refuse trade.

**Soil Exhaustion** — All tiles resentful. Crop yields near zero. Farm struggles.

**Shame Legacy** — Grandfather's broken oath haunts every generation. NPCs remember. Reputation never fully recovers.

---

## Player Goals Per Generation

### Generation 1: Survival
- Survive first winter
- Establish farm
- First marriage
- Build basic production

### Generation 2: Growth
- Expand production
- Multiple marriages
- Faction relationships
- Soil memory management

### Generation 3+: Legacy
- Shape entropy path
- Honor/break family obligations
- Build reputation or accept shame
- Prepare for ending

---

## Tuning Philosophy

### Hostile But Fair

The world challenges players but never cheats. Death probabilities increase with age (realistic). Resource costs are transparent. RNG exists but is weighted toward interesting outcomes.

### Story > Grind

Progression comes from choices, not repetition. Titles earned through milestones (harvest 200 crops), not XP. Stat gains from actions, not grinding.

### Consequences Matter

Every choice echoes. Plant the same crop repeatedly → soil resents. Break a contract → faction remembers. Push entropy hard → ending triggers early.

### Emergent Narrative

No scripted story. The story emerges from player choices, NPC memories, rumors, and world events. Each playthrough tells a different tale.

---

## Balance Levers

### Economy
- **Crop yields**: Base output + soil mood modifier + soilcraft stat
- **Trade prices**: Base price × faction reputation modifier
- **Travel costs**: Days × food/fuel consumption

### Time
- **Day advancement**: Manual (player clicks "Advance Day")
- **Year length**: 120 days (4 seasons × 30 days)
- **Aging**: 1 year per year (duh)

### Difficulty
- **Death probability**: 1% base + (age - 43) × 2% + injuries × 5%
- **Encounter rate**: Configurable (default 30% per travel day)
- **Weather frequency**: 10-20% chance per year for major events

---

## Glossary

**Entropy** — Measure of Order (0-100) vs Wild (0-100). Actions push meters. High entropy triggers ending events.

**Order Path** — Machine-aligned future. Builds machines, favors biomechanical crops, increases Order entropy.

**Wild Path** — Nature-aligned future. Preserves pure soil, favors biological crops, increases Wild entropy.

**Heirloom** — Artifact passed through generations. Provides stat bonuses, unlocks abilities, carries family history.

**Ferro-Soil** — Metal-rich soil favoring biomechanical crops. High machine affinity, low nature affinity.

**Ashfall** — Weather type. Dark particles fall like snow. Silences sounds, reduces visibility.

**Soil Memory** — Each tile remembers: crops planted, years used, mood (neutral → content → resentful → exhausted).

---

**Cross-References:**

- [Lore Bible](LORE_BIBLE.md) • [Systems](../SYSTEMS/farming_system.md) • [Player Guide](PLAYER_GUIDE/getting_started.md) • [Technical](TECHNICAL/architecture_overview.md)

