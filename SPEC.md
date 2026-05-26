# Iron and Alms — Specification & Architecture

see [DESIGN.md](DESIGN.md) for game design, mechanics, and data model.

---

## 1. Technology Stack

| component   | choice                            | notes                                          |
| :---------- | :-------------------------------- | :--------------------------------------------- |
| language    | Go 1.22+                          | static binary, `CGO_ENABLED=0`, cross-platform |
| rendering   | [Ebitengine](https://ebiten.org/) | Go-native 2D engine, no CGO                    |
| data / save | JSON + SQLite                     | JSON for config/asset tables, SQLite for saves |
| build tool  | Make                              | standard across all repos                      |
| dev reload  | [air](https://github.com/air-verse/air) | live reload on file save; `make dev`    |
| asset mgr   | procedural PNG + sprite sheets    | embedded via `go:embed` at build time          |
| music/sfx   | OGG via `stb_audio`               | fallback: silent on unsupported builds         |

#### Why Go?

- **Static single-binary builds** — `CGO_ENABLED=0` produces a self-contained executable for all platforms. no runtime dependencies, no installers.
- **Turn-based system logic first** — tactical combat, company management, procedural world generation are all data/logic heavy problems where Go excels.
- **Full test suite** — `go test` covers core game logic independently of rendering. no GPU required for testing.
- **Cross-compilation** — `GOOS=linux GOARCH=amd64` produces binaries for every major platform from a single host.
- **Ebitengine maturity** — stable, actively maintained, targets Windows/macOS/Linux/Android/Web. sprite-based rendering is sufficient for a turn-based RPG.

---

## 2. Architecture

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

| package   | owns                                                         | does not own            |
| :-------- | :----------------------------------------------------------- | :---------------------- |
| `core/`   | company roster, unit stats, combat rules, inventory, economy | rendering, save data    |
| `world/`  | procedural world map, factions, events, terrain, religion    | game loop, combat logic |
| `data/`   | save/load, schema, configuration tables, embedded assets     | game logic, rendering   |
| `engine/` | game loop, state machine, input dispatching                  | core rules, persistence |
| `ui/`     | Ebitengine rendering, menus, HUD, dialogs                    | game rules, engine      |

### Cross-Package Communication

```
ui ──▶ engine ──▶ core ──▶ world ──▶ data
ui ◀── engine ◀── core ◀── world ◀── data
```

packages only import packages directly below them. no cross-wiring upward. interfaces defined in the consumer package define the boundary.

---

## 3. File Structure

```
iron-and-alms/
├── main.go                 # entry point: ebitgame.Run(game)
├── Makefile
├── go.mod
├── AGENT.md
├── CLAUDE.md -> AGENT.md
├── README.md
├── DESIGN.md
└── SPEC.md
core/                       # game logic: company, combat, economy
world/                      # procedural generation, factions
data/                       # save/load, config, assets
engine/                     # game loop, state machine
ui/                         # rendering, menus, HUD
```

---

## 4. Complexity Score

| dimension | score | notes                                      |
| :-------- | :---- | :----------------------------------------- |
| overall   | 3 / 5 | moderate; multi-package with protocol work |

---

## 5. Roadmap

### near term

- [ ] `[project]` confirm technology stack and language  [easy]
- [ ] `[project]` scaffold project structure (Makefile, build, test targets)  [easy]
- [ ] `[project]` update Makefile to be standard  [easy]
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

## 6. Decisions

| decision   | choice              | rationale                                                                 |
| :--------- | :------------------ | :------------------------------------------------------------------------ |
| language   | Go + Ebitengine     | single static binary; zero runtime deps; fastest local setup for OSS     |
| dev reload | air                 | closes iteration gap; hot rebuild <1s on incremental changes              |
