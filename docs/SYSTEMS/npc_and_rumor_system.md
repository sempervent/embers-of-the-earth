╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — NPC & RUMOR SYSTEM    ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"Old Mara remembers when your grandfather broke the contract. She remembers everything. The soil remembers. The people remember." — Settlement Wisdom*

---

## At a Glance

The NPC and rumor system manages named characters with opinions (-100..+100), daily schedules, memory of past events, and procedural rumor generation/propagation. NPCs remember your bloodline's actions. Rumors spread and fade over time.

---

## What It Simulates

- **NPC Personalities**: Named characters with traits, factions, opinions
- **Opinion System**: -100 (hate) to +100 (love) toward player bloodline
- **Memory System**: NPCs remember events (broken contracts, marriages, betrayals)
- **Daily Schedules**: NPCs appear at different locations at different times
- **Rumor Lifecycle**: Birth → Propagation → Decay → Death

---

## Data It Owns

### NPC State

```json
{
  "id": "mara_old",
  "name": "Old Mara",
  "role": "Storyteller",
  "faction": "Rootbound",
  "age": 78,
  "location": "settlement_square",
  "schedule": {
    "morning": "farm_gate",
    "noon": "settlement_square",
    "evening": "tavern"
  },
  "opinion": {
    "Coalroot_bloodline": -10,
    "Brass_Guild": 20
  },
  "traits": ["wise", "skeptical"],
  "memory": [
    {"event": "grandfather_broke_contract", "year": 15, "opinion_change": -30},
    {"event": "player_married_brass_guild", "year": 22, "opinion_change": -10}
  ]
}
```

### Rumor State

```json
{
  "id": "rumor_bandit_attack",
  "text": "They say the Coalroot heir never made it to town. Bandits wear gear-masks now.",
  "source": "bandit_attack_brassford",
  "type": "event",
  "delivery_method": "tavern",
  "created_day": 45,
  "decay_days": 60,
  "propagated_to": ["brassford", "ash_caravan"],
  "heard_by_player": false
}
```

---

## Signals & Events

- `npc_opinion_changed(npc_id, target_id, new_opinion)` — Emitted when opinion changes
- `npc_aged(npc_id, new_age)` — Emitted each year on birthday
- `new_rumor_available(rumor_text, source, type)` — Emitted when rumor generated
- `rumor_propagated(rumor_id, to_settlement)` — Emitted when rumor spreads
- `rumor_decayed(rumor_id)` — Emitted when rumor expires

---

## Player-Facing Effects

### NPC Opinions

**Range**: -100 (hate) to +100 (love)

**Display**: Shown in NPC dialogue panel

**Effects**:
- **Positive (>20)**: Friendly dialogue, better trade prices, offers help
- **Neutral (-20 to +20)**: Standard dialogue, normal prices
- **Negative (<-20)**: Hostile dialogue, higher prices, refuses trade

### Memory System

**NPCs Remember**:
- Broken contracts (grandfather's shame)
- Marriages (faction relationships)
- Betrayals (shame events)
- Generous deeds (reputation boost)

**Memory Decay**: Events older than 3 generations lose opinion impact (but not forgotten)

### Daily Schedules

**Locations**: NPCs move between locations based on time of day

- **Morning**: Farm gate, market stall, workshop
- **Noon**: Settlement square, tavern, market
- **Evening**: Home, tavern, settlement square

**Player Action**: Find NPCs at their scheduled locations for dialogue/trade

### Rumor Delivery

**Channels**:
1. **Journal** — Written entries appear in player journal
2. **Tavern** — Overheard dialogue when visiting tavern
3. **Market** — NPCs mention rumors during trade
4. **Letter** — Letters arrive from NPCs
5. **Overheard** — Random whispers in settlement

**Content**: Rumors reference player actions, world events, faction politics

---

## Rumor Lifecycle

### Birth

**Triggers**:
- World events (settlement burns, faction collapse)
- Player actions (betrayal, marriage, heirloom loss)
- Random generation (5% chance per day)

**Initial State**:
- Created at source settlement
- Decay timer starts (default: 60 days)
- Propagation chance (30% per day)

### Propagation

**Mechanism**: Each day, rumor has 30% chance to spread to adjacent settlement

**Spread Pattern**:
- Settlement A → Settlement B (if connected)
- Maximum 3 settlements per rumor
- Each propagation resets decay timer by 20 days

### Decay

**Mechanism**: Each day, rumor's decay_days decrements

**Death**: When decay_days reaches 0, rumor is removed

**Extension**: Propagation adds 20 days to decay timer

### Death

**Triggers**: Decay_days reaches 0

**Effect**: Rumor removed from active rumors list

**Memory**: Some rumors persist in journal (historical record)

---

## Opinion Calculation

### Base Opinion

```json
{
  "faction_base": 0,
  "trait_modifier": 0,
  "memory_events": [],
  "current": 0
}
```

### Memory Impact

**Broken Contract**: -30 per generation removed (-30 → -15 → -7 → 0)

**Marriage**: +10 for allied faction, -10 for rival faction

**Betrayal**: -20 permanent (never fully recovers)

**Generous Deed**: +5 temporary (decays -1 per year)

---

## Balance Levers

- **Opinion Range**: -100 to +100 (fixed)
- **Memory Decay**: Generations until forgotten (default: 3)
- **Rumor Birth Rate**: Chance per day (default: 5%)
- **Rumor Propagation**: Chance per day (default: 30%)
- **Rumor Decay**: Days until expiration (default: 60)

**Safe Tweaks**:
- Adjust rumor birth/propagation rates (±5%)
- Modify decay timer (±10 days)
- Tune opinion modifiers (±5 points)

**Risky Tweaks**:
- Removing memory system (removes core mechanic)
- Auto-forgetting all events (breaks immersion)

---

## Failure Modes

### NPC Death

**Cause**: NPCs age and can die (rare event)

**Result**: NPC removed from system. Opinions lost.

**Recovery**: None. NPC is gone.

### Rumor Explosion

**Cause**: Too many events trigger too many rumors

**Result**: Journal flooded, player overwhelmed

**Recovery**: Decay system handles this naturally (rumors expire)

### Memory Overflow

**Cause**: Too many memory events stored per NPC

**Result**: Performance degradation (unlikely with current limits)

**Recovery**: Memory decay prevents overflow

---

## Example Rumor Fragments

### Settlement Burns

*"They say the Coalroot farm survived the fire. Others say they started it."* — Market Gossip

*"After the fire, Brassford's prices doubled. The machine-god's anger or greed?"* — Tavern Chatter

### Faction Collapse

*"The Root Keepers have scattered. Their ancient pacts mean nothing now."* — Letter from NPC

*"Refugees from the Rootbound lands seek shelter. They bring stories and seeds."* — Settlement News

### Heirloom Theft

*"The Coalroot heirloom seeds are gone. Stolen or lost—same difference."* — Market Whisper

*"They say bandits wear gear-masks now. Some say they're the faces of old machines."* — Traveler's Tale

---

## Rumor Delivery Example

```json
{
  "rumor": {
    "id": "rumor_grandfather_contract",
    "text": "Your grandfather broke a contract with the Brotherhood. That debt is yours now.",
    "source": "broken_contract_event",
    "type": "memory",
    "delivery_method": "tavern",
    "created_day": 15,
    "decay_days": 60
  },
  "delivery": {
    "method": "tavern",
    "npc": "mara_old",
    "context": "Old Mara whispers over her ale: 'I remember when your grandfather broke the contract. The Brotherhood never forgets.'"
  }
}
```

---

**Cross-References:**

- [Game Design](../GAME_DESIGN.md) • [Lore Bible](../LORE_BIBLE.md) • [Lineage System](lineage_system.md) • [Player Guide](../PLAYER_GUIDE/marriage_and_factions.md) • [Technical](../TECHNICAL/architecture_overview.md)

