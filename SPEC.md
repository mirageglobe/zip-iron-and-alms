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

see [DESIGN.md](DESIGN.md) for full system design. roadmap follows the 8-layer build order — complete each layer before starting the next.

### layer 1 — resource pressure (near term)

- [ ] `[project]` scaffold project structure (Makefile, build, test targets)  [easy]
- [ ] `[company]` implement company data model (roster, fighters, stats, wounds)  [medium]
- [ ] `[company]` implement daily wage deduction and gold tracking  [easy]
- [ ] `[company]` implement wound system — bench fighters, daily healing tick  [medium]
- [ ] `[equipment]` implement equipment degradation and repair cost  [medium]
- [ ] `[combat]` implement auto battle resolution (fatigue, morale, formation)  [hard]
- [ ] `[world]` implement node-based world map with travel cost in days  [medium]
- [ ] `[contract]` implement basic contract — accept, travel, resolve, pay  [medium]

### layer 2 — reputation

- [ ] `[reputation]` implement five-tier reputation score  [easy]
- [ ] `[contract]` gate contract availability by reputation tier  [easy]

### layer 3 — consequence flags

- [ ] `[world]` implement faction/town relationship flags (hostile/neutral/friendly/allied)  [medium]
- [ ] `[contract]` flip relationship flags based on contract outcomes  [medium]

### layer 4 — faction drift + crisis events

- [ ] `[world]` implement faction strength score with daily drift  [medium]
- [ ] `[world]` implement faction collapse and expansion at strength thresholds  [medium]
- [ ] `[world]` implement continental crisis events (mongol expansion, plague, noble war)  [hard]

### layer 5 — generational play

- [ ] `[company]` implement fighter age counter and death by old age  [easy]
- [ ] `[company]` implement legacy trait assigned on veteran death  [medium]

### ideas (layers 6–8)

- [ ] `[faith]` piety as per-fighter resource; sin events; morale and combat consequences  [medium]
- [ ] `[alchemy]` regional ingredients; 10–15 recipes; alchemy trait for advanced recipes  [medium]
- [ ] `[equipment]` named equipment with history flags  [easy]
- [ ] `[world]` free roam map — wilderness between nodes becomes explorable  [hard]
- [ ] `[world]` far east regions unlock via exploration  [medium]
- [ ] `[reputation]` kingmaker tier — company shapes faction outcomes  [hard]
- [ ] `[narrative]` authored campaign event chains layered on sandbox  [hard]

---

## 6. Decisions

| decision   | choice              | rationale                                                                 |
| :--------- | :------------------ | :------------------------------------------------------------------------ |
| language   | Go + Ebitengine     | single static binary; zero runtime deps; fastest local setup for OSS     |
| dev reload | air                 | closes iteration gap; hot rebuild <1s on incremental changes              |
