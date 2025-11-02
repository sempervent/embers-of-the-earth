╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — LINEAGE SYSTEM        ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"When you die, control passes to your child. Your shame becomes theirs. Your heirlooms become theirs. Your legacy becomes theirs." — Bloodline Codex*

---

## At a Glance

The lineage system manages generational succession, trait inheritance, heirloom passing, and death mechanics. When the player dies, control transfers to an heir. Shame and glory echo across generations.

---

## What It Simulates

- **Aging**: Player ages 1 year per year
- **Death**: Probability increases with age and injuries
- **Inheritance**: Traits, heirlooms, stats passed to children
- **Succession**: Control passes to oldest eligible heir
- **Legacy**: Family tree tracks generations

---

## Data It Owns

### Player State

```json
{
  "name": "Elias Coalroot",
  "age": 43,
  "generation": 1,
  "traits": ["ironblood", "soilbound"],
  "stats": {
    "resolve": 15,
    "mechanica": 12,
    "soilcraft": 18,
    "diplomacy": 10,
    "vigor": 14
  },
  "heirlooms": ["first_farmers_letter", "cracked_music_locket"],
  "injuries": [],
  "parents": null
}
```

### Child Data

```json
{
  "name": "Iris Coalroot",
  "age": 18,
  "generation": 2,
  "traits": ["ironblood", "wise"],
  "stats": {
    "resolve": 13,
    "mechanica": 11,
    "soilcraft": 16,
    "diplomacy": 12,
    "vigor": 13
  },
  "heirlooms": [],
  "injuries": [],
  "parents": ["Elias Coalroot", "Mara Brassford"]
}
```

### Family Tree

```json
{
  "generations": [
    {
      "generation": 1,
      "successor": {"name": "Elias Coalroot", "age": 43, "year": 1},
      "spouse": null,
      "children": [{"name": "Iris Coalroot", "age": 18}]
    },
    {
      "generation": 2,
      "successor": {"name": "Iris Coalroot", "age": 18, "year": 25},
      "spouse": {"name": "Thaddeus Forgehand", "faction": "machinists"},
      "children": []
    }
  ]
}
```

---

## Signals & Events

- `player_aged(age)` — Emitted each year on birthday
- `player_died(player_data)` — Emitted when death triggers
- `heir_selected(heir_data)` — Emitted when heir takes control
- `trait_inherited(trait_name, from_parent)` — Emitted on trait inheritance
- `heirloom_passed(heirloom_id, from_generation, to_generation)` — Emitted on heirloom inheritance

---

## Player-Facing Effects

### Aging

- **Automatic**: Each year advance, player ages 1 year
- **Display**: Age shown in player info panel
- **Effect**: Death probability increases with age

### Death Probability

```
Base: 1%
Age penalty: (age - 43) × 2%
Injury penalty: injuries × 5%
Total: base + age + injuries
```

**Example**: Age 50, 1 injury = 1% + 14% + 5% = 20%

### Heir Selection

- **Criteria**: Oldest child aged 18+
- **If no children**: Game ends (extinction)
- **If multiple eligible**: Choose eldest
- **If none exist**: Soft fail → NPC adoption (rare event)

### Inheritance

**Traits**: 70% chance to inherit each parent's trait (up to 2 total)

**Stats**: Average of both parents × inheritance_factor (0.7) + random variation (±2)

**Heirlooms**: All owned heirlooms pass to heir automatically

**Reputation**: Faction opinions inherited at 50% value

**Shame**: Broken contracts pass to next generation

---

## Death Mechanics

### Hard Death

**Cause**: Age + injuries + bad luck

**Process**:
1. Death probability calculated
2. RNG roll
3. If death triggers:
   - Save player state
   - Find eligible heir
   - Transfer control
   - Emit `player_died` event
   - Show death screen

### Soft Death (Extinction)

**Cause**: No eligible heirs

**Process**:
1. Player dies
2. Check for children aged 18+
3. If none exist:
   - Game ends
   - Extinction ending triggers
   - Epilogue shows abandoned farm

---

## Trait Inheritance

### Parent Traits

```json
{
  "parent1_traits": ["ironblood", "soilbound"],
  "parent2_traits": ["wise", "strong"]
}
```

**Inheritance**: Child gets 0-2 traits randomly selected from parents

**Probability**: 70% chance per parent trait

**Example**: Child might inherit `["ironblood", "wise"]` or `["soilbound"]` or none

---

## Stat Inheritance

### Formula

```
For each stat:
  parent1_value = parent1.stat[stat_name]
  parent2_value = parent2.stat[stat_name]
  average = (parent1_value + parent2_value) / 2
  inheritance_factor = 0.7
  inherited = average × inheritance_factor
  variation = random(-2, +2)
  final = clamp(inherited + variation, 0, 100)
```

**Example**:
- Parent 1: Resolve 50
- Parent 2: Resolve 40
- Average: 45
- Inherited: 45 × 0.7 = 31.5
- Variation: +1
- Final: 32

---

## Heirloom Inheritance

### Automatic Transfer

- All owned heirlooms pass to heir
- Heirlooms retain generation count
- Lost heirlooms stay lost (can't recover)

### Heirloom Effects

- **Stat Bonuses**: Apply to heir immediately
- **Faction Access**: Unlocks locations/settlements
- **Story Items**: Provide lore, unlock events

---

## Balance Levers

- **Death Probability**: Base rate and age penalty multiplier
- **Trait Inheritance**: Probability (default: 70%)
- **Stat Inheritance**: Factor (default: 0.7)
- **Heir Age Requirement**: Minimum age (default: 18)

**Safe Tweaks**:
- Adjust base death probability (±1%)
- Modify trait inheritance probability (±10%)
- Tune stat inheritance factor (±0.1)

**Risky Tweaks**:
- Removing age requirement (breaks immersion)
- Auto-succession without choice (reduces agency)

---

## Failure Modes

### No Heirs (Extinction)

**Cause**: Player dies with no children aged 18+

**Result**: Game ends. Extinction ending triggers.

**Recovery**: None. New game required.

### All Heirlooms Lost

**Cause**: Bandits steal heirlooms, death before recovery

**Result**: Heir inherits nothing. Stat bonuses lost.

**Recovery**: Can't recover lost heirlooms. Play with disadvantage.

### Shame Legacy

**Cause**: Grandfather broke faction contract

**Result**: Faction remembers. Reputation never fully recovers.

**Recovery**: Takes multiple generations of good deeds to reduce shame

---

## Example Heir Selection

```json
{
  "player": {
    "name": "Elias Coalroot",
    "age": 53,
    "generation": 1,
    "children": [
      {"name": "Iris Coalroot", "age": 28, "eligible": true},
      {"name": "Marcus Coalroot", "age": 25, "eligible": true},
      {"name": "Luna Coalroot", "age": 15, "eligible": false}
    ]
  },
  "death": {
    "triggered": true,
    "year": 35,
    "cause": "old_age"
  },
  "heir": {
    "name": "Iris Coalroot",
    "age": 28,
    "generation": 2,
    "inherited_traits": ["ironblood"],
    "inherited_stats": {"resolve": 14, "mechanica": 11},
    "inherited_heirlooms": ["first_farmers_letter", "cracked_music_locket"]
  }
}
```

---

**Cross-References:**

- [Game Design](../GAME_DESIGN.md) • [Lore Bible](../LORE_BIBLE.md) • [Farming System](farming_system.md) • [Player Guide](../PLAYER_GUIDE/lineage_and_heirs.md) • [Technical](../TECHNICAL/architecture_overview.md)

