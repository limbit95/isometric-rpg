# Isometric RPG — STEP 0

A standalone **Godot 4.7.2**, **GDScript**, 2D isometric action RPG foundation.
This repository is entirely separate from Unreal Engine and other projects.

## Current state (STEP 0)

- Godot `TileMapLayer` with a procedural `TileSetAtlasSource`, **64×32 isometric diamond tiles**, 20×20 test map.
- A placeholder sprite, 4-way/8-way analogized keyboard movement (`WASD` / arrow keys), camera follow, floor-edge bounds checking.
- Self-contained `main.tscn`; no external paid assets and no network dependency at runtime.
- Python structural checks and Godot headless runtime smoke test.
- GitHub Actions workflow for PR/push CI with a pinned Godot 4.7.2 binary.

> This is **not yet a combat prototype**. Attacks, obstacles, gameplay physics, AI, save system, and exports belong to subsequent steps. The ground tileset is generated at startup; STEP 1 should convert to an editable artist-maintained TileSet.

## Open in Godot (Windows)

1. Install **Godot Engine 4.7.2 Standard**, not .NET, from https://godotengine.org/download/archive/4.7.2-stable/ .
2. Extract the project ZIP, keeping this `project.godot` at the project root.
3. Open Godot Project Manager → **Import** → choose `project.godot` → **Import & Edit**.
4. Press **F6** from `scenes/main.tscn` or **F5** to play the project.
5. Move with `WASD` / arrow keys; `Esc` quits. The placeholder player should remain on the isometric floor.

## Run verification

Windows PowerShell (replace the quoted path to the Godot executable):

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\verify.ps1 -Godot "C:\Tools\Godot_v4.7.2-stable_win64.exe"
```

Linux / GitHub Actions:

```bash
GODOT_BIN=/path/to/godot bash tools/verify.sh
```

Checks:
1. Python contract tests (requires Python 3 only; no third-party packages).
2. Godot headless import and scene/script parsing.
3. Godot headless `tests/smoke_runner.gd`: validates isometric shape, 64×32 tiles, 400 cells, spawn and input actions.

**Note:** Godot scripts still need runtime confirmation with Godot 4.7.2. A successful static Python test is not a successful Godot engine run.

## Create a separate GitHub repository

Create a **new private empty repository** named `isometric-rpg-step0` under your GitHub account. Do **not** choose automatic README or `.gitignore` creation. In the extracted project directory:

```bash
git init -b main
git add .
git commit -m "chore: bootstrap Godot 4.7.2 STEP0"
git remote add origin https://github.com/limbit95/isometric-rpg-step0.git
git push -u origin main
```

The remote URL above works **only after you create the new repository**. This package does not change any existing repository. Enable GitHub Actions if prompted and inspect the `Godot STEP0 verification` workflow result.

For future steps, create `feature/step1-combat` from `main`, open a PR, wait for the CI check, then manually approve and merge. See `docs/agents/AI_TASK_RULES.md`.

## Scope and non-goals

- Offline single-player first. No authentication, database, multiplayer, telemetry, or Supabase.
- Only sample pixel graphics made for this prototype. Replace with rights-cleared sprites later.
- No pre-existing Unreal or GitHub project was modified.
- A release executable is not generated in STEP 0; export presets/templates will be introduced when packaging is part of the scope.

## Directory layout

```text
assets/characters/       Placeholder player image
assets/tiles/            Placeholder 2-tile isometric atlas
scenes/                  Instantiable main scene
scripts/game/            Composition/input binding
scripts/world/           Runtime isometric tilemap
scripts/player/          CharacterBody2D movement
tests/                   Python and Godot smoke tests
tools/                   Windows and Linux validation scripts
data/                    Future content (items, enemies, skills, quests)
docs/architecture/       Architecture decisions
docs/agents/             AI implementation constraints
docs/story/              Story input contract
docs/tasks/              Acceptance criteria
.github/workflows/       Remote verification
```
