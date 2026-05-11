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

| component     | choice                      | notes                                  |
| :-----------  | :-------------------------- | :------------------------------------- |
| language      | Go 1.22+                  | static binary, `CGO_ENABLED=0`, cross-platform |
| rendering     | [Ebitengine](https://ebiten.org/)| Go-native 2D engine, no CGO         |
| data / save   | JSON + SQLite             | JSON for config/asset tables, SQLite for saves |
| build tool    | Make                       | standard across all repos              |
| asset mgr     | procedural PNG + sprite sheets | embedded via `go:embed` at build time |
| music/sfx     | OGG via `stb_audio`        | fallback: silent on unsupported builds |

#### Why Go?

- **Static single-binary builds** — `CGO_ENABLED=0` produces a self-contained executable for all platforms. no runtime dependencies, no installers.
- **Turn-based system logic first** — tactical combat, company management, procedural world generation are all data/logic heavy problems where Go excels.
- **Full test suite** — `go test` covers core game logic independently of rendering. no GPU required for testing.
- **Cross-compilation** — `GOOS=linux GOARCH=amd64` produces binaries for every major platform from a single host.
- **Ebitengine maturity** — stable, actively maintained, targets Windows/macOS/Linux/Android/Web. sprite-based rendering is sufficient for a turn-based RPG.

#### Architecture Rationale

```
┌───────────────────────────────────────┐
│  Ebitengine UI (ui/)                  │  ← rendering only
│  ─────────────────────────────────   │
│  Game Engine (engine/)                │  ← game loop, input processing
│  ─────────────────────────────────   │
│  Core Systems (core/, world/, etc.)   │  ← pure logic, no deps on UI
│  ─────────────────────────────────   │
│  Data Layer (data/)                   │  │  persistence, asset loading
└───────────────────────────────────────┘
```

core and data packages are UI-independent. they can be tested with `go test` in isolation. the engine and ui packages wrap around core systems.

---

## 4. Architecture

the project follows a layered architecture with clear separation between rendering and game logic. core systems have no dependencies on UI packages — they operate on pure data.

```
┌─────────────────────────────────────────────────────────┐
│  ebitengine (ui/)                                         │
│    ┌────────────┐  ┌────────────┐  ┌────────────┐       │
│    │  main menu  │  │   HUD      │  │   combat   │       │
│    │  rendering │  │  rendering │  │   render   │       │
│    └────────────┘  └────────────┘  └────────────┘       │
│    └─────── calls into engine.Game ──────────┘            │
├─────────────────────────────────────────────────────────┤
│  engine/                                                  │
│    ┌────────────┐  ┌────────────┐  ┌────────────┐       │
│    │  GameLoop  │  │  WorldMgr  │  │  Combat    │       │
│    │            │  │            │  │   state    │       │
│    └────────────┘  └────────────┘  └────────────┘       │
│    └─────── calls into core/ and world/ ──────────┘       │
├─────────────────────────────────────────────────────────┤
│  core/  (roster, combat rules, inventory, economy)        │
│  world/ (procedural map, factions, events, religion)      │
│  data/  (save/load, asset tables, config)                  │
│  all pure logic, no UI or engine deps                      │
└─────────────────────────────────────────────────────────┘
```

### Package Responsibilities

| Package  | Owns                                          | Does NOT Own         |
| :------- | :---------------------------------------------| :--------------------|
| `core/`  | Company roster, unit stats, combat rules, inventory, economy   | rendering, save data |
| `world/` | Procedural world map, factions, events, terrain, religion        | game loop, combat logic |
| `data/`  | Save/load, schema, configuration tables, embedded assets        | game logic, rendering |
| `engine/`| Game loop, state machine, input dispatching | core rules, persistence |
| `ui/`    | Ebitengine rendering, menus, HUD, dialogs   | game rules, engine   |

### Cross-Package Communication

```
ui ──▶ engine ──▶ core ──▶ world ──▶ data
ui ◀── engine ◀── core ◀── world ◀── data
```

packages only import packages directly below them. no cross-wiring upward. interfaces defined in the consumer package define the boundary.

### Core Data Model (Outline)

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

## 5. File Structure

```
iron-and-alms/
├── main.go                 # entry point: ebitgame.Run(game)
├── Makefile
├── go.mod
├── AGENT.md
├── CLAUDE.md -> AGENT.md
├── README.md
└── SPEC.md
core/                       # game logic: company, combat, economy
world/                      # procedural generation, factions
data/                       # save/load, config, assets
engine/                     # game loop, state machine
ui/                         # rendering, menus, HUD
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

| dimension    | score | notes                                     |
| :---------- | :---- | :--------------------------------------- |
| overall      | 3 / 5 | moderate; multi-package with protocol work|

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
