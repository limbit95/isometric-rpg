# Isometric RPG — Godot 4.7.2

A standalone **2D isometric action RPG prototype** using Godot 4.7.2 Standard + typed GDScript. This is a new independent repository; no Unreal or other game repository is touched.

## STEP 0 (committed to main)

- 64×32 isometric TileMapLayer / 20×20 checkerboard arena.
- WASD or arrow-key movement, placeholder sprite, Camera2D follow.
- Python and Godot headless smoke tests.

## STEP 1 (merged into main — PR #1)

- Mouse **left click** performs a single short melee strike in the clicked direction.
- Attack range **84 px**, forward arc **110°**, damage **2 HP**, cooldown **0.4 s**.
- Three stationary pink/red training dummies (4 HP each); two hits defeat a dummy.
- Each dummy has a health bar; HUD counts defeated targets.
- Physical hit detection queries **Area2D** hurtboxes on collision layer 4.
- Damage and death behavior isolated in a reusable **HealthComponent**.

Controls: WASD/arrow keys = move, left click near a dummy = attack, Esc = exit. To respawn all targets, restart F5.

Enemy AI, enemy attacks, equipment, item drops, save files and combat animations are **not implemented** in this step.

## Start in Godot (Windows)

1. Download [Godot 4.7.2 Standard](https://godotengine.org/download/archive/4.7.2-stable/).
2. Git checkout `feature/step1-basic-combat` (or review the pull request), open `project.godot` from the repository root.
3. Press **F5** and move near one of the red targets.
4. Point at the target and left-click; the translucent yellow wedge indicates the attack arc.
5. Hit twice with at least 0.4 seconds between strikes. Verify the target disappears and the HUD count increments.
6. Verify basic WASD movement and map edges still work.

## Verify (no paid dependencies)

Windows PowerShell (replace the Godot executable path):

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\verify.ps1 -Godot "C:\Tools\Godot_v4.7.2-stable_win64.exe"
```

Linux / GitHub Actions:

```bash
GODOT_BIN=/path/to/godot bash tools/verify.sh
```

Verification includes Python structural checks, Godot headless asset import, preserved STEP 0 smoke, and STEP 1 combat smoke. **STEP 2 is a separate feature branch and still requires green CI, manual gameplay verification, and explicit approval before merging to main.**

## Workflow

Use one isolated `feature/step*-*` branch per task, open a pull request to `main`, and merge only after review and testing. See [STEP 1 acceptance](docs/tasks/STEP1_ACCEPTANCE.md) and [AI task rules](docs/agents/AI_TASK_RULES.md). No automatic merging or writes to other repositories.


## STEP 2 — Enemy AI (feature/step2-enemy-ai, pending PR)

- Keeps the existing three stationary training targets and all STEP 1 combat controls.
- Two orange enemies patrol no route but detect the player (215px), pursue by direct movement, telegraph a melee hit (0.28s), and deal 2 HP every 1.15s while in range (43px).
- The player has 12 HP; a zero-health player cannot move or attack. Restart F5 to reset.
- Chasers return to their home positions after exceeding 330px leash or player death. They have 8 HP each.
- No wall-aware pathfinding, advanced navigation or animations yet. See `docs/tasks/STEP2_ACCEPTANCE.md` for acceptance and limits.
- Verification: `tools/verify.sh` or `tools/verify.ps1` runs Python structure checks and three Godot smoke tests (STEP0/1/2).
