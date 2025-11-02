# Content Templates

Use these templates to add new content to Embers of the Earth without touching code.

## Available Templates

### 1. Crop Template (`crop_template.json`)

**Usage:**
1. Copy `crop_template.json`
2. Rename to your crop name (e.g., `steelwheat.json`)
3. Fill in all fields
4. Place in `data/crops/` directory
5. Game automatically loads new crops

**Key Fields:**
- `name`: Unique identifier (no spaces)
- `growth_stages`: Number of growth stages (3-7)
- `requires`: Resources needed (array)
- `output`: Items produced (array)
- `likes`: Preferred soil types (array)
- `hates`: Incompatible soil types (array)
- `biomechanical`: Boolean (affects entropy)
- `lore`: Backstory and legend

**Example:**
```json
{
  "name": "Steelwheat",
  "growth_stages": 6,
  "requires": ["iron", "steam", "water"],
  "output": ["grain", "steel_scrap"],
  "likes": ["ferro_soil", "scrap_heap"],
  "hates": ["pure_bio_soil"],
  "biomechanical": true
}
```

### 2. NPC Template (`npc_template.json`)

**Usage:**
1. Copy `npc_template.json`
2. Fill in NPC details
3. Add quotes for different opinion levels
4. Place in `data/npcs/npcs.json` (add to array)
5. NPCs appear at specified settlements

**Key Fields:**
- `id`: Unique identifier
- `name`: Display name
- `faction`: Faction affiliation
- `settlement`: Where they appear
- `quotes`: Context-based quotes (neutral/positive/negative/rumor)
- `memory_events`: Events they remember
- `lore`: Backstory and secrets

### 3. Event Template (`event_template.json`)

**Usage:**
1. Copy `event_template.json`
2. Define trigger conditions
3. Set effects
4. Write rumor/journal templates
5. Place in `data/world/events/world_events.json` (add to array)

**Key Fields:**
- `trigger_conditions`: When event occurs (year, entropy, travel, etc.)
- `effects`: What changes in the world
- `rumors`: Templates for rumors generated
- `journal_entries`: Templates for journal entries
- `lore`: Significance and consequences

## Content Guidelines

### Writing Style

- **Melancholic but hopeful**
- **No bright colors** - everything rusts, fades
- **Memory and legacy** - everything echoes
- **Consequences matter** - choices have weight

### Naming Conventions

- **Crops**: Descriptive + biomechanical (e.g., Steelwheat, Rustmoss)
- **NPCs**: Name + role/faction (e.g., Mara Brassford, Thaddeus Forgehand)
- **Events**: Verb + noun (e.g., Settlement Burns, Faction Collapse)
- **Heirlooms**: Possessive + item (e.g., First Farmer's Letter)

### Balancing Guidelines

- **Crops**: 3-7 growth stages, 2-5 days per stage
- **NPCs**: 3-5 quotes per opinion level
- **Events**: 5-15% chance per year for major events
- **Heirlooms**: 1-3 stat bonuses, meaningful lore

## Adding Content

### Quick Start

1. Choose template type (crop/NPC/event)
2. Copy template file
3. Fill in fields
4. Add to appropriate JSON file
5. Test in game

### Testing New Content

- Use dev console: `spawn [item] [qty]`
- Use debug overlay: `toggle_heatmap`
- Check journal entries appear correctly
- Verify NPC quotes match opinion levels

## Expansion Goals

### Current Content
- Crops: 4
- NPCs: 6
- Events: 6
- Heirlooms: 6

### Target Content
- Crops: 12
- NPCs: 20
- Events: 15
- Heirlooms: 12

---

Use these templates to expand the world without touching code!

