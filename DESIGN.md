# Iron and Alms — Game Design Document

> a medieval tactical RPG inspired by Darklands, Jagged Alliance, and Battle Brothers.

---

## 1. Overview

**Iron and Alms** is a dark, historically grounded medieval game where the player commands a small company of fighters — mercenaries, faithful, and desperate souls — navigating a brutal world of conflict, survival, and moral weight. the name captures the two currencies of the setting: iron (violence, war, survival) and alms (faith, charity, moral cost).

### Design Philosophy

**gritty and consequential.** decisions carry weight — men die, resources run thin, loyalties shift. no hand-holding; the player reads the world and acts on incomplete information. the game is systemic rather than scripted: emergent stories arise from interacting rules, not authored cutscenes.

### Core Pillars

**resource pressure**
- equipment degrades with use; repair costs money and time
- daily wages bleed gold whether the company fights or rests
- wounds bench fighters — a hurt roster is a revenue problem, not just a stat problem

**world that pushes back**
- factions don't wait — they expand, skirmish, and respond to the company's actions
- contracts have windows; miss them and the opportunity (and reputation) is gone
- towns can fall, roads become dangerous, prices shift with faction control

**mercenary commander fantasy**
- the player is never on the battlefield — they command, not fight
- personality as mechanics, not narrative: traits (cowardly, greedy, devout, stubborn) modify behaviour directly — no dialogue system needed
- loyalty score rises with wins and pay, falls with losses and neglect; low loyalty means desertion risk
- grudge flag between two fighters applies a morale penalty when grouped
- hard calls: cut a wounded man to save wages, take a morally ugly contract to make payroll

### Structure

**sandbox first, campaigns second.** the base game is a persistent sandbox — no win condition, no narrative spine. the world evolves without the player: factions war, towns fall, events fire regardless of what the company does. replayability comes from emergent stories, not authored content.

campaign stories layer on top as authored event chains once the world feels alive — a threat emerges, factions respond, the player chooses their role. the sandbox remains the foundation; campaigns are an optional narrative lens over it.

### Long Arc Design

**one principle: systems over content.** every mechanic should generate stories, not require writing them. one well-designed system produces hundreds of hours of unique situations. authored content runs out; systems don't.

**the minimal set that creates long-arc play**

- **consequence flags** — a tag on factions and towns: `hostile / neutral / friendly / allied`; actions flip flags; flags change what's available
- **fighter age and death** — fighters gain an age counter; old veterans get a legacy trait when they die; new recruits start blank; generational play emerges
- **faction drift** — each faction has a `strength` score that ticks up or down based on world events; at zero they collapse; at max they expand
- **reputation tier** — five tiers, one number; gates available contracts and who approaches you

**build order**

| layer | systems                                        |
| :---- | :--------------------------------------------- |
| 1     | resource pressure (wages, equipment, wounds)   |
| 2     | reputation tier                                |
| 3     | consequence flags                              |
| 4     | faction drift + crisis events                  |
| 5     | generational play (age + legacy traits)        |
| 6     | depth systems (faith, alchemy, named equipment)|
| 7     | continental scale (exploration, kingmaker tier)|
| 8     | campaign stories (authored event chains)       |

each layer adds depth and works independently — stop at any point and the game is playable.

**the long tail**
- community-authored campaigns using the same event system
- moddable factions, regions, and recipe lists — core is systems-based so everything is data
- a company that survives long enough becomes legend; the game never needs to end

### Setting

**the silk road era (circa 1200–1350).** a continent spanning Europe, the Levant, Persia, Central Asia, and the edges of China. factions are historically grounded but not bound to strict history — the world is a living system, not a textbook.

the Mongol expansion is the continental pressure valve: khanates push west and south, factions fall or adapt, trade routes shift, and the mercenary market spikes along every new front.

**factions**

| faction                  | character                                              |
| :----------------------- | :----------------------------------------------------- |
| crusader states          | faith-driven, resource-poor, desperate for mercenaries |
| islamic sultanates       | wealthy, politically fractured, sophisticated          |
| byzantine remnants       | bureaucratic, defensive, pay well but demand loyalty   |
| mongol khanates          | expansionist, unpredictable, continental threat        |
| silk road merchant guilds| no armies; deal in money, goods, and information       |

**faith**
- christian, islamic, and buddhist piety systems with different costs and benefits
- holy sites, relics, and pilgrim contracts scattered across the map
- religious tension as a contract driver

**economy**
- trade goods move along the silk road; the company protects, raids, or escorts caravans
- war disrupts trade; trade funds war — the loop is self-sustaining
- contract availability and pay rates shift with faction control of regions

### Inspirations

| game            | what we draw from                                                  |
| :-------------- | :----------------------------------------------------------------- |
| Darklands       | dark historical realism, faith mechanics, alchemy, moral ambiguity |
| Jagged Alliance | mercenary management, inventory depth, character personality       |
| Battle Brothers | company-scale tactics, permadeath, procedural world events         |

---

## 2. Goals

| goal                                             | status |
| :----------------------------------------------- | :----- |
| turn-based tactical combat on a tile grid        | [ ]    |
| company management (roster, morale, pay, wounds) | [ ]    |
| procedural world map with events and contracts   | [ ]    |
| faith and reputation systems                     | [ ]    |
| permadeath with persistent world consequences    | [ ]    |
| equipment and inventory with medieval realism    | [ ]    |

---

## 3. Core Data Model

```
Company
├── Roster []Fighter
│   ├── Fighter: ID, Name, Class, Level, HP, STR/DEX/CON/INT/WIS/CHA
│   ├── Wounds: []Wound{location, severity, days}
│   └── Morale: trait, loyalty, piety
├── Funds: gold
├── Strength: int  (combat-ready count)
└── Reputation: []FactionRep{name, standing}

Combat
└── Battle: TurnBased
    ├── Map []Tile
    ├── Units []BattleUnit
    ├── OrderQueue []Order
    └── Result: enum{player_victory, retreat, defeat}
```

---

## 4. Systems

### Combat

turn-based, tile grid. movement, attack, and line-of-sight rules define engagement. flanking, weapon reach, and terrain affect outcomes.

**battles are won before they start.** the strategy layer is where iron and alms lives — the tactical layer resolves decisions already made. a commander who managed resources well, read the contract carefully, and picked the right fighters should win most fights.

**pre-battle decisions**
- **contract intelligence** — pay for better information before accepting; cheap contracts come with no intel
- **approach route** — how you reach the battlefield affects starting position and fighter fatigue
- **roster selection** — deploying a wounded fighter is a choice with consequences
- **conditions** — weather and time of day are set before the fight, not during

the player is a commander, not a soldier. the planning phase is the game.

**auto battle**
battles resolve automatically based on formation, stats, traits, fatigue, and morale. the player sets up the fight; the system plays it out.

- set formation and roles (front line, archer, reserve) before resolving
- watch at normal speed or skip to result
- chaos is intentional — morale variance, injury rolls, and fatigue spikes mean the outcome is never perfectly predictable; good preparation wins most fights, not all

**combat resolution model (Battle Brothers inspired)**
- each fighter has two resources: **fatigue** (depletes from armour, actions, injuries) and **action points** (move + attack per turn)
- fatigue degrades effectiveness over a long fight — a strong opener can become a liability
- morale checks trigger on heavy losses; fighters can break and flee regardless of orders
- formation-based positioning (front line holds, backline supports) over fine AP management

### Company Management

roster of named fighters with persistent stats, wounds, and morale. fighters demand pay; morale degrades under loss, hunger, or unpaid wages.

### World

procedural map of regions, towns, and wilderness. factions control territory; contracts from lords, merchants, and churches drive the economy.

### Faith

piety is a per-fighter resource, not a flavour bar. it is spent by prayer and rebuilt through action — attending rites, completing pilgrimages, honouring oaths.

**sin is mechanical** — certain contract types, battlefield decisions, and oath-breaking reduce piety directly. a company that takes dirty work gradually loses access to divine aid.

**consequences**
- low piety: morale penalty, prayers fail
- high piety: small combat bonus, access to holy site contracts

**the silk road tension** — three faith systems (christian, islamic, buddhist) operate across the continent. crossing religious boundaries has cost: taking a contract for the sultanate may reduce piety for christian fighters. faith creates geopolitical friction without a dialogue system.

### Alchemy

a preparation system rooted in the silk road setting — islamic, byzantine, and chinese alchemical traditions each contribute to the recipe pool.

**ingredients are regional and finite** — sourced as loot or purchased at specific town types. what you find in the Levant differs from Central Asia or China; exploration has material reward.

**recipes are small in number (10–15)**
- healing salves, fire oil, smoke bombs, antitoxins, stimulants
- advanced recipes locked behind an alchemy trait on a fighter

**constraints**
- crafting takes time — a fighter preparing supplies isn't available for combat
- consumables reward preparation, not tactical mistakes
- short recipe list and scarce ingredients prevent it overwhelming the inventory layer

### Economy

medieval contract economy. income from military contracts; expenses from wages, equipment, and upkeep.

### Reputation

faction standing gates available contracts and town access. actions in the world are remembered.
