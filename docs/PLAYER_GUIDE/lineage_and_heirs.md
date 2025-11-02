╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — LINEAGE & HEIRS       ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"When you die, control passes to your child. Your shame becomes theirs. Your heirlooms become theirs. Your legacy becomes theirs." — Bloodline Codex*

---

## At a Glance

This guide covers generational succession: aging, death mechanics, heir selection, trait inheritance, heirloom passing, and legacy building. When you die, control transfers to an heir. Shame and glory echo across generations.

---

## Aging & Death

### Aging

**Automatic**: Each year advance, player ages 1 year

**Display**: Age shown in player info panel

**Effects**: Death probability increases with age

**Formula**: `base(1%) + (age - 43) × 2% + injuries × 5%`

**Example**: Age 50, 1 injury = 1% + 14% + 5% = 20% death chance

**[FIELD NOTE]**

*Death probability increases significantly after age 43. Plan succession before age 50. Have children early.*

---

### Death Mechanics

**Hard Death**: Age + injuries + bad luck

**Process**:
1. Death probability calculated each year
2. RNG roll (if death triggers)
3. Save player state
4. Find eligible heir
5. Transfer control
6. Show death screen

**Soft Death (Extinction)**: No eligible heirs

**Result**: Game ends. Extinction ending triggers.

**Recovery**: None. New game required.

---

## Heir Selection

### Criteria

**Minimum Age**: 18 years old

**Selection**: Oldest eligible child

**If No Children**: Game ends (extinction)

**If Multiple Eligible**: Choose eldest

**If None Exist**: Soft fail → NPC adoption (rare event)

---

### Inheritance

**Traits**: 70% chance to inherit each parent's trait (up to 2 total)

**Stats**: Average of both parents × 0.7 + random variation (-2 to +2)

**Heirlooms**: All owned heirlooms pass to heir automatically

**Reputation**: Faction opinions inherited at 50% value

**Shame**: Broken contracts pass to next generation

---

## Raising Children

### Child Birth

**Trigger**: Marriage completes (first child born 1 year later)

**Process**:
1. Spouse moves to farm
2. Child born (age 0)
3. Child added to family tree

**Note**: Children grow 1 year per year (automatic)

---

### Child Traits

**Inheritance**: Children inherit traits from both parents

**Probability**: 70% chance per parent trait

**Example**:
- Parent 1: ["ironblood", "soilbound"]
- Parent 2: ["wise", "strong"]
- Child might inherit: ["ironblood", "wise"] or ["soilbound"] or none

**Random Factor**: Inheritance is not guaranteed

---

### Child Stats

**Calculation**: Average of both parents × 0.7 + random variation

**Example**:
- Parent 1: Resolve 50
- Parent 2: Resolve 40
- Average: 45
- Inherited: 45 × 0.7 = 31.5
- Variation: +1
- Final: 32

**Range**: Clamped to 0-100

---

### Child Education

**Current System**: No explicit education mechanic

**Future Expansion**: May add education choices (apprenticeship, schooling)

**Current Effect**: Children inherit parents' stats/traits automatically

---

## Heirloom System

### Automatic Transfer

**Process**: All owned heirlooms pass to heir when you die

**Retention**: Heirlooms retain generation count

**Loss**: Lost heirlooms stay lost (can't recover)

---

### Heirloom Effects

**Stat Bonuses**: Apply to heir immediately

**Faction Access**: Unlocks locations/settlements

**Story Items**: Provide lore, unlock events

**Example Heirlooms**:
- First Farmer's Letter: +2 Soilcraft
- Cracked Music Locket: Plays ancestral theme
- Heirloom Seeds: +15% crop yield
- Grandfather's Broken Contract: -15 faction reputation (shame)

---

### Heirloom Loss

**Causes**:
- Bandit theft (during travel encounters)
- World events (settlement burns, faction collapse)
- Entropy events (machine-god tremors)

**Prevention**:
- Avoid risky travel routes
- Protect heirlooms at settlements (if possible)
- Accept loss (can't always prevent)

**Recovery**: Lost heirlooms cannot be recovered

---

## Legacy Building

### Family Reputation

**Building**: Complete contracts, honor obligations, generous deeds

**Effects**: Faction opinions affect trade prices, marriage opportunities

**Degradation**: Break contracts, betrayals, shame events

**Inheritance**: Faction opinions inherited at 50% value

---

### Family Shame

**Causes**:
- Grandfather broke faction contract
- Betrayal of allies
- Lost heirlooms

**Effects**:
- Faction opinions permanently negative
- NPCs remember (memory system)
- Reputation never fully recovers

**Inheritance**: Shame passes to next generation

---

### Family Glory

**Causes**:
- Honored contracts for generations
- Generous deeds to factions
- Preserved heirlooms

**Effects**:
- Faction opinions permanently positive
- NPCs remember (memory system)
- Reputation persists across generations

**Inheritance**: Glory passes to next generation

---

## Succession Planning

### Early Planning

**Timeline**: Arrange marriage by age 35

**Reasoning**: 
- Children born 1 year after marriage
- Child reaches 18 at player age 53+
- Death probability high after age 50

**Strategy**: Have multiple children (backup heirs)

---

### Multiple Heirs

**Advantage**: Backup if primary heir dies

**Disadvantage**: None (no inheritance splitting)

**Selection**: Always eldest eligible heir

**Strategy**: Have 2-3 children for safety

---

### Heirloom Protection

**Strategy**: Don't travel with critical heirlooms

**Alternative**: Store heirlooms at settlements (if possible)

**Risk**: World events can still destroy heirlooms

**Acceptance**: Some heirlooms may be lost

---

## If X Then Y Playbook

### If You Die Without Heirs

**Then**: Game ends. Extinction ending triggers.

**Prevention**: Always have children before age 50

---

### If Primary Heir Dies

**Then**: Next eldest child becomes heir

**Prevention**: Have multiple children (backup)

---

### If All Heirlooms Lost

**Then**: Heir inherits nothing. Stat bonuses lost.

**Prevention**: Protect heirlooms, avoid risky travel

**Recovery**: Accept loss (can't recover)

---

### If Grandfather's Shame Haunts You

**Then**: Faction opinions permanently negative

**Prevention**: None (inherited shame)

**Recovery**: Generous deeds reduce shame over generations

---

**Cross-References:**

- [Getting Started](getting_started.md) • [Marriage & Factions](marriage_and_factions.md) • [Lineage System](../SYSTEMS/lineage_system.md) • [Technical](../TECHNICAL/architecture_overview.md)

