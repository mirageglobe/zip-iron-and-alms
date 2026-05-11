# Iron and Alms — Agent Instructions

this document is intended for AI coding assistants working in the `iron-and-alms` directory.

## Commands

- **Build**: `make build`
- **Test**: `make test`
- **Run**: `make run`
- **Format**: `make fmt`
- **Lint**: `make lint`

## Project Context

- **Description**: a medieval tactical RPG inspired by Darklands, Jagged Alliance, and Battle Brothers. players lead a small company of fighters navigating a dark, historically grounded medieval world — managing their crew, resources, and moral choices across turn-based combat and strategic decisions.
- **Language**: Go 1.22+ (Ebitengine for 2D rendering)
- **Architecture**: see `SPEC.md` for full architectural details.

## Coding Conventions

- keep source files under ~150 lines; split by responsibility when exceeded.
- write unit tests first before implementation (TDD).
- inline comments only for non-obvious "why" logic — never describe what the code does.
- run linters before committing.
- **Git Commits**: do not include `Co-authored-by` trailers.
- **Aesthetics**: prefer clean ASCII and Unicode characters over emoji for terminal output.
- **Diagrams**: structure all architectural or logic diagrams using clean ASCII or Unicode characters.
- **Tables**: ensure all Markdown tables are highly readable by maintaining perfect column alignment and spacing.

## Conventions

- **Branch**: never commit directly to `main`. use `YYYYMMDD-adjective-noun` branch naming (e.g. `20260420-wise-swan`).
- **Commit Messages**: concise title; body includes `[ TL;DR ]` and bullet points.
- **Zero-Secrets Policy**: never commit secrets, tokens, or credentials.
