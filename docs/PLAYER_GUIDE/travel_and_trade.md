╔══════════════════════════════════════════════╗
║   EMBERS OF THE EARTH — TRAVEL & TRADE        ║
╚══════════════════════════════════════════════╝

Build: Early Access • Docs v1.0

> *"The road is dangerous. But the settlements await. Trade connects all. Rumors spread. Your legacy travels with you." — Traveler's Codex*

---

## At a Glance

This guide covers overworld travel, route planning, encounters, hazards, settlements, and trade mechanics. The wasteland is dangerous. Preparation and planning save lives.

---

## Travel Basics

### Route Planning

**Action**: Open map (press **M**), select destination settlement

**Display**:
- Distance (days of travel)
- Food cost (per day)
- Fuel cost (per day)
- Hazard probability (per region)

**Decision**: Confirm travel or cancel

---

### Travel Costs

**Formula**: `days × (food_per_day + fuel_per_day)`

**Example**: 5 days travel = 5 food + 10 fuel

**Display**: Costs shown before confirmation

**Warning**: Zero food or fuel → travel stops mid-journey

**[FIELD NOTE]**

*Always stockpile 2× travel costs before journey. Encounters may delay travel, increasing costs.*

---

### Travel Process

**Time**: Each travel day advances game clock

**Resources**: Food and fuel consumed per day

**Encounters**: 30% chance per day for random event

**Hazards**: Weather events, breakdowns, ambushes

**Progress**: Travel screen shows days remaining

---

## Encounters

### Encounter Rate

**Probability**: 30% chance per travel day

**Types**:
- **Bandits** — Gear-masked scavengers demanding tribute
- **Merchants** — Wandering traders offering goods
- **Machine-Beasts** — Twisted mechanical creatures
- **Refugees** — Survivors seeking help
- **Faction Patrol** — Friendly or hostile depending on reputation

---

### Encounter Resolution

**Choice-Based**: Not action combat

**Options**: Pay, flee, negotiate, fight

**Stat Tests**: Resolve, Diplomacy, Vigor determine outcomes

**Example**:
- **Pay Tribute**: Lose resources, avoid combat
- **Flee**: Test Resolve (success = escape, fail = injury)
- **Negotiate**: Test Diplomacy (success = reduced cost, fail = higher cost)
- **Fight**: Test Resolve (success = win, fail = serious injury)

**[FIELD NOTE]**

*Your stats matter. High Resolve improves flee/fight success. High Diplomacy improves negotiation. High Vigor reduces injury severity.*

---

## Hazards

### Weather Events

**Ashfall**: Slows travel, reduces visibility

**Storms**: Delay travel, damage crops/buildings

**Heat Waves**: Increase water consumption

**Drought**: Zero water collection, crop failure

**Preparation**: Check weather forecast (if available), delay travel if severe

---

### Breakdowns

**Causes**: Vehicle/equipment failures during travel

**Effects**: Time delay (+1-3 days), resource loss (repair costs)

**Prevention**: Maintain equipment, avoid long journeys

**Recovery**: Accept delay, continue journey

---

### Ambushes

**Causes**: Surprise attacks by bandits/machine-beasts

**Effects**: Stat test (flee/fight), injury possible, heirloom theft possible

**Prevention**: Choose safe routes (lower encounter rate)

**Recovery**: Treat injuries, continue journey

---

## Settlements

### Settlement Types

**Brassford** (Fortified Trading Post):
- **Faction**: Brass Guild of Machinists
- **Economy**: Metal goods, blueprints, mechanical parts
- **Marriage Rules**: Allows machinists, requires ironwheat tribute

**Root Keepers' Grove** (Hidden Settlement):
- **Faction**: Root Keepers
- **Economy**: Bio seeds, herbs, organic fertilizer
- **Marriage Rules**: Allows Root Keepers, requires preservation oath

**Rust Gate** (Military Outpost):
- **Faction**: Rusted Brotherhood
- **Economy**: Weapons, armor, security contracts
- **Marriage Rules**: Allows Brotherhood, requires loyalty oath

**Ash Caravan Camp** (Nomadic Camp):
- **Faction**: Ash Caravans
- **Economy**: General goods, provisions, maps
- **Marriage Rules**: Allows all factions, requires protection payment

---

### Settlement Access

**Requirements**: None (all settlements accessible)

**Restrictions**: Some areas require faction reputation or heirlooms

**Example**: Root Keepers' Grove requires Root Keeper's Seal heirloom

---

### Settlement Economy

**Sells**: Items available for purchase

**Buys**: Items they want from you

**Prices**: Base price × reputation modifier

**Reputation Effects**:
- Reputation >20: -10% discount
- Reputation -20 to +20: 0% markup
- Reputation <-20: +20% markup

---

## Trade Mechanics

### Trade Menu

**Action**: Visit settlement, open trade menu

**Display**:
- Items available (sells)
- Items they want (buys)
- Player inventory
- Faction reputation
- Current prices (with modifiers)

---

### Price Calculation

**Formula**: `final_price = base_price × (1 + reputation_modifier)`

**Example**:
- Base price: 10
- Reputation: 30 (friendly)
- Modifier: -10%
- Final price: 10 × 0.9 = 9

---

### Trade Strategies

**Sell Excess Crops**:
- Harvest more than needed
- Sell at settlements for metal parts
- Buy fuel/tools with profit

**Buy Low, Sell High**:
- Check prices at multiple settlements
- Buy where cheap, sell where expensive
- Profit from price differences

**Faction Reputation**:
- Improve reputation for better prices
- Trade with friendly factions first
- Accept price markup if necessary

---

## Route Planning

### Safe Routes

**Criteria**: Lower encounter rate, shorter distance

**Trade-offs**: May be longer (more days = more costs)

**Strategy**: Balance safety vs speed

---

### Dangerous Routes

**Criteria**: Higher encounter rate, shorter distance

**Trade-offs**: More encounters = more risks

**Strategy**: Only if well-prepared (high stats, good supplies)

---

### Multi-Settlement Journeys

**Strategy**: Visit multiple settlements in one journey

**Planning**: Map route to minimize backtracking

**Costs**: Cumulative (days × costs per settlement)

---

## If X Then Y Playbook

### If Encounter Goes Bad

**Minor Injury** (cuts, bruises):
- Continue journey (with stat penalties)
- Treat at next settlement (if possible)
- Rest if severe (delay journey)

**Serious Injury** (serious cuts):
- Return to settlement immediately
- Visit healer (costs resources)
- Rest 2-3 days before continuing

**Heirloom Theft**:
- Accept loss (can't recover)
- Continue journey (if possible)
- Report at settlement (generates rumor)

---

### If Out of Supplies Mid-Journey

**Food Exhausted**:
- Find nearest settlement immediately
- Trade for food (or trade heirlooms if desperate)
- Return home before starvation

**Fuel Exhausted**:
- Walk to nearest settlement (slower, consumes food)
- Trade for fuel
- If stuck: soft fail (wait for rescue)

---

### If Settlement Prices Too High

**Bad Reputation**:
- Complete generous deeds (improve reputation)
- Accept markup (if necessary)
- Trade with other settlements (if accessible)

**World Event**:
- Wait for event to pass (prices normalize)
- Trade elsewhere (if possible)
- Stockpile before events (if predictable)

---

### If Faction Refuses Trade

**Hostile Reputation**:
- Complete contracts (rebuild reputation)
- Accept shame (if grandfather's fault)
- Trade with other factions (if accessible)

**Access Restricted**:
- Acquire required heirloom (if applicable)
- Improve faction reputation (if applicable)
- Accept limitation (can't access)

---

## Advanced Trade Tips

### Price Arbitrage

**Strategy**: Buy low at one settlement, sell high at another

**Example**: 
- Buy grain at Brassford (2 gold)
- Sell grain at Ash Caravan (3 gold)
- Profit: 1 gold per unit

**Requirement**: Access to multiple settlements

---

### Seasonal Pricing

**Pattern**: Some items cheaper in certain seasons

**Example**: Fuel cheaper in winter (less demand)

**Strategy**: Stockpile during cheap seasons, sell during expensive seasons

---

### Faction Loyalty Discounts

**Strategy**: Maintain high reputation with one faction

**Benefit**: Consistent 10% discount on all trades

**Trade-off**: May limit other faction relationships

---

**Cross-References:**

- [Getting Started](getting_started.md) • [Survival Guide](survival_guide.md) • [Overworld System](../SYSTEMS/overworld_and_travel.md) • [Technical](../TECHNICAL/architecture_overview.md)

