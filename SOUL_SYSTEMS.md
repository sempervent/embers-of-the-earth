# Soul Systems - Meaning & Memory Implementation

## ✅ Implemented Systems

### 1. NPC System ✅

**Files:**
- `scripts/npcs/NPCSystem.gd` - NPC management
- `data/npcs/npcs.json` - NPC database

**Features:**
- ✅ Named NPCs at settlements (5-10 per settlement)
- ✅ Personality traits (skeptical, wise, grumpy, proud, etc.)
- ✅ Daily schedules (morning/noon/evening locations)
- ✅ Opinion system (-100 to 100) based on bloodline actions
- ✅ Memory system (NPCs remember contract breaks, marriages, betrayals)
- ✅ Age and death (NPCs age and can die, affecting relationships)
- ✅ Contextual quotes based on opinion and past events
- ✅ Opinion changes based on player actions

**NPCs Included:**
- Old Mara (Brassford elder) - Remembers past marriages, skeptical of iron wombs
- Thaddeus Forgehand (Brassford smith) - Proud, values steel and contracts
- Elysium Wander (Ash Caravan merchant) - Diplomatic, knows all the roads
- Elara Greenthumb (Root Keepers elder) - Mystical, sees past in leaves
- Captain Ironwill (Rust Gate commander) - Vengeful, remembers broken contracts
- Tav the Tale-Teller (Neutral gossip) - Spreads rumors everywhere

### 2. Rumor System ✅

**Files:**
- `scripts/world/events/RumorSystem.gd` - Rumor generation and delivery
- Integrated with NPC system and world events

**Features:**
- ✅ Procedural rumor generation from templates
- ✅ Multiple delivery methods: journal, tavern, market, letter, overheard
- ✅ Rumor propagation (spreads between settlements)
- ✅ Rumor lifecycle (fades after 60 days)
- ✅ Context-aware rumors (references player name, factions, settlements)
- ✅ Integration with journal system

**Rumor Types:**
- Bandit attacks
- Contract breaks
- Heirloom loss
- NPC deaths
- Settlement events
- Marriage scandals
- Machine-god events

### 3. Dynamic World Events ✅

**Files:**
- `scripts/world/events/WorldEventSystem.gd` - Event management
- `data/world/events/world_events.json` - Event definitions

**Features:**
- ✅ 6 major world events that change the game
- ✅ Conditional triggers (year, entropy, generation, travel)
- ✅ Settlement burns → price spikes, refugees
- ✅ Faction collapse → voided contracts
- ✅ Bandit heirloom theft → lost family history
- ✅ Machine-god awakening → new prophet/settlements
- ✅ Wild reclamation → nature consumes settlements
- ✅ Grandfather's broken contract → shame across generations
- ✅ Automatic rumor generation from events
- ✅ Journal entries for player

**Events:**
1. Settlement Burns
2. Faction Collapse
3. Heirloom Theft
4. Machine Prophet Emerges
5. Wild Reclamation
6. Grandfather's Broken Contract

### 4. Heirloom System ✅

**Files:**
- `scripts/npcs/HeirloomSystem.gd` - Heirloom management
- `data/heirlooms/heirlooms.json` - Heirloom definitions

**Features:**
- ✅ Heirlooms passed through generations
- ✅ 6 unique heirlooms with emotional weight
- ✅ Effects: stat bonuses, faction access, ancestral music
- ✅ Loss system (can be stolen/lost permanently)
- ✅ Inheritance to next generation
- ✅ Journal entries for acquisition/loss/inheritance
- ✅ Shame artifacts (broken contracts, mistakes)

**Heirlooms:**
1. First Farmer's Letter - Soil-stained, foundational
2. Cracked Music Locket - Plays ancestral theme
3. Heirloom Seeds - Pure genetics, can be stolen
4. Grandfather's Broken Contract - Shame artifact
5. Scarred Machine Blueprint - Blood-stained history
6. Root Keeper's Seal - Faction access

### 5. Family Tree UI ✅

**Files:**
- `scripts/ui/FamilyTreeUI.gd` - Family tree interface

**Features:**
- ✅ Visual family tree across generations
- ✅ Generation selection
- ✅ Character portraits (placeholder system)
- ✅ Character info display (name, age, traits, parents)
- ✅ Trait inheritance visualization
- ✅ Portrait display system (ready for procedural generation)

## Emotional Depth Systems

### Memory Across Generations

NPCs remember:
- Broken contracts from grandfather's time
- Marriage alliances (positive or negative)
- Theft of heirlooms
- Faction betrayals
- Reputation built or lost

Quotes reflect memory:
- "I remember when your kin broke the contract."
- "Your grandfather knew better than to trust machines."
- "The old ways are dying. Your bloodline chose metal over life."

### Shame & Regret

Heirlooms carry shame:
- Broken contracts passed down
- Decisions that haunt generations
- NPCs remember and judge based on past

Rumors spread shame:
- "They say your kin brought the bandits."
- "Nothing good grows from iron wombs."
- "Your ancestors left a stain on that name."

### Hope & Legacy

Heirlooms carry hope:
- First Farmer's Letter: foundational wisdom
- Heirloom Seeds: untainted genetics
- Music Locket: connection to ancestors

NPCs offer redemption:
- Positive quotes when reputation improves
- Memory can be balanced by new actions
- Contracts can be honored despite past

## Integration Points

### With Existing Systems

**NPC System** connects to:
- LineageSystem (marriage memories)
- RumorSystem (generates rumors)
- SettlementController (NPC locations)
- JournalSystem (quotes in journal)

**Rumor System** connects to:
- NPCSystem (delivery via NPCs)
- WorldEventSystem (event rumors)
- JournalSystem (journal entries)
- AtmosphereManager (world feeling alive)

**World Events** connect to:
- SettlementController (price changes)
- LineageSystem (voided contracts)
- HeirloomSystem (stolen heirlooms)
- RumorSystem (event rumors)

**Heirlooms** connect to:
- Player stats (bonuses)
- FactionSystem (access)
- MusicSystem (ancestral themes)
- JournalSystem (inheritance entries)

## Usage Examples

### Meeting an NPC

```gdscript
var npc_system = get_tree().get_first_node_in_group("npc_system") as NPCSystem
var npc_id = "mara_brassford"

# Get NPC quote based on opinion
var quote = npc_system.get_npc_quote(npc_id, "neutral")
print(quote)  # "Nothing good grows from iron wombs."

# Check opinion
var opinion = npc_system.get_npc_opinion(npc_id)
# -20 (negative, remembers past contract break)

# Change opinion through actions
npc_system.change_opinion(npc_id, 10, "honored_contract")
```

### Generating Rumors

```gdscript
var rumor_system = get_tree().get_first_node_in_group("rumor_system") as RumorSystem

# Generate rumor from event
rumor_system.generate_rumor("bandit_attack", {
    "player_name": "Elias Coalroot",
    "settlement": "Brassford"
})
# Creates: "Bandits attacked the Elias Coalroot caravan..."

# Rumor automatically delivers via random method
# Could appear in journal, tavern dialogue, market chatter, etc.
```

### World Events

```gdscript
var event_system = get_tree().get_first_node_in_group("world_events") as WorldEventSystem

# Events check automatically each year
# When conditions are met, event triggers:
# - Settlement burns
# - Faction collapses
# - Heirlooms stolen
# - Machine-god awakens
```

### Heirlooms

```gdscript
var heirloom_system = get_tree().get_first_node_in_group("heirlooms") as HeirloomSystem

# Start with heirlooms in generation 1
# "first_farmer_letter", "cracked_music_locket", "heirloom_seeds"

# Lose heirloom (permanent)
heirloom_system.lose_heirloom("heirloom_seeds", "Stolen by bandits")

# Pass to next generation
heirloom_system.pass_to_next_generation(successor_data)
```

## Emotional Weight Examples

### Example 1: The Broken Contract

**Generation 1:** Player breaks contract with Brass Guild
**Generation 3:** NPCs still remember
- Old Mara: "I remember when your grandfather broke the contract."
- Opinion: -30
- Rumor spreads: "The Brass Guild say the Coalroots broke a contract. Trust is gone."
- Heirloom appears: "Grandfather's Broken Contract" (shame artifact)

### Example 2: The Stolen Seeds

**Travel:** Player travels to settlement
**Event:** Bandit heirloom theft triggered
**Effect:** Heirloom Seeds permanently lost
**Rumor:** "The Coalroot heirloom seeds are gone. Stolen by bandits wearing gear-masks."
**Emotional:** "Everything the first farmer saved—gone."

### Example 3: Settlement Burns

**Event:** Settlement Burns triggers
**Effect:** Prices spike, refugees appear
**Rumor:** "{settlement} burned. They say it was the machine-god's anger."
**Journal:** "News reaches the farm: {settlement} has burned. Prices will spike."
**NPC Quotes:** NPCs react with fear, speculation

## Next Steps

### Remaining Work

1. **Character Portraits** - Procedural generation system
2. **Family Tree UI** - Visual polish and interactions
3. **Letter System** - Physical letters as items
4. **Wanted Posters** - Visual consequences of betrayals
5. **Grave Markers** - Memorial UI for deceased family
6. **Marriage Contracts** - Visual contract UI with portraits

### Polish Needed

- NPC dialogue UI integration
- Rumor delivery UI (tavern, market, letters)
- Family tree visual polish
- Portrait generation pipeline
- Letter reading interface

---

**Status**: ✅ Core soul systems complete - World feels alive with people, memories, and consequences

