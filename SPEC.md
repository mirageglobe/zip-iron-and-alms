# Iron and Alms — Specification & Architecture

> a medieval tactical RPG inspired by Darklands, Jagged Alliance, and Battle Brothers.

---

## 1. Overview

**Iron and Alms** is a dark, historically grounded medieval game where the player commands a small company of fighters — mercenaries, faithful, and desperate souls — navigating a brutal world of conflict, survival, and moral weight. the name captures the two currencies of the setting: iron (violence, war, survival) and alms (faith, charity, moral cost).

### Design Philosophy

**gritty and consequential.** decisions carry weight — men die, resources run thin, loyalties shift. no hand-holding; the player reads the world and acts on incomplete information. the game is systemic rather than scripted: emergent stories arise from interacting rules, not authored cutscenes.

### Inspirations

| game              | what we draw from                                                  |
| :---------------- | :----------------------------------------------------------------- |
| Darklands          | dark historical realism, faith mechanics, alchemy, moral ambiguity |
| Jagged Alliance    | mercenary management, inventory depth, character personality       |
| Battle Brothers    | company-scale tactics, permadeath, procedural world events         |

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

## 3. Technology Stack

| component    | choice  | notes                       |
| :----------- | :------ | :-------------------------- |
| language     | TBD     |                             |
| rendering    | TBD     |                             |
| data / save  | TBD     |                             |
| build tool   | Make    | standard across all repos   |

---

## 4. Architecture

> TBD — to be defined once the tech stack is confirmed.

high-level layers to design for:

```
┌───────────────────────────────────────┐
│               UI / Renderer           │
├───────────────────────────────────────┤
│           Game Loop / Engine          │
├──────────────┬────────────────────────┤
│   World Sim  │   Combat Engine        │
├──────────────┴────────────────────────┤
│        Data / Persistence Layer       │
└───────────────────────────────────────┘
```

---

## 5. File Structure

```
iron-and-alms/
├── Makefile
├── AGENT.md
├── CLAUDE.md -> AGENT.md
├── README.md
└── SPEC.md
```

---

## 6. Complexity Score

| dimension   | score | notes                                    |
| :---------- | :---- | :--------------------------------------- |
| overall     | TBD   | to assess once stack and scope are fixed |

---

## 7. Roadmap

### near term

- [ ] `[project]` confirm technology stack and language  [easy]
- [ ] `[project]` scaffold project structure (Makefile, build, test targets)  [easy]
- [ ] `[combat]` define tile-based combat rules (movement, attack, line of sight)  [hard]
- [ ] `[company]` define company data model (roster, stats, wounds, morale, pay)  [medium]
- [ ] `[world]` design procedural world map and event system  [hard]

### ideas

- [ ] `[faith]` faith and divine favour mechanics — prayer, relics, miracles with real cost  [medium]
- [ ] `[economy]` medieval contract economy — work for lords, merchants, churches  [medium]
- [ ] `[reputation]` faction reputation system affecting available contracts and town access  [medium]
- [ ] `[alchemy]` Darklands-style alchemy for consumables and battlefield effects  [hard]
- [ ] `[narrative]` procedural event text with historically grounded flavour  [hard]

---

## 8. Decisions

| decision | choice | rationale |
| :------- | :----- | :-------- |
| TBD      |        |           |
