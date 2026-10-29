# Isometric RPG — Godot 4.7.2

Standalone 2D isometric action RPG prototype. Repository: `limbit95/isometric-rpg`. All other projects remain untouched.

## Progress

- **STEP 0 (main):** isometric 64×32 TileMapLayer (20×20 cells), WASD movement, Camera2D and automated smoke tests.
- **STEP 1 (main, PR #1):** left-click directional melee, 2 damage, 0.4s cooldown, three training dummies, reusable HealthComponent.
- **STEP 2 (main, PR #2):** two orange enemies chase/attack/return, player 12 HP and death blocking, AI smoke tests.
- **STEP 3 (feature branch, pending):** Q cone (3 damage, 5 MP, 1.3s cooldown); E bolt projectile (5 damage, 7 MP, 1.8s cooldown); mana regeneration; cooldown HUD.

## Play STEP 3

Switch to `feature/step3-skills-mana` branch and open `project.godot` in Godot 4.7.2 Standard.

- `WASD` / arrows: move
- `Left click`: melee
- `Q`: cone attack toward mouse pointer (126px, 100°)
- `E`: single-hit bolt toward mouse pointer (360px/s, max 330px travel after muzzle offset)
- `Esc`: exit

The mana pool starts at 20 MP and regains 1 MP each second while alive. The HUD shows MP, HP and skill cooldown timers. Restart with F5 to reset.

## Verification

On Windows PowerShell, from the project root:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\verify.ps1 -Godot "C:\Tools\Godot_v4.7.2-stable_win64.exe"
```

On Linux:

```bash
GODOT_BIN=/path/to/Godot bash tools/verify.sh
```

The GitHub Actions workflow runs Python structure tests, headless import, STEP0 map, STEP1 combat, STEP2 AI, and STEP3 skill runtime checks on every push and PR.

## Scope and review

This is a deliberately small offline single-player test arena: original placeholder artwork, no animations, sounds, quests, item drops, inventory, wall-aware projectile collision or multiplayer. Do not merge the STEP 3 PR without both successful CI and user play-testing. See `docs/tasks/STEP3_ACCEPTANCE.md`.


## STEP 4 (feature branch, not yet merged)

- Chasers give 5 XP each; 10 XP advances from level 1 to 2, then 15 XP for the next level.
- Dummies drop yellow Iron Shards; first chaser drops blue Training Blade, second drops purple Focus Charm.
- Walk onto colored diamonds to collect into the 8-slot bag; shard stacks up to 20, equipment is nonstackable.
- Press `1` after collecting blade to equip +1 basic attack; `2` after collecting charm to equip +4 max MP.
- HUD displays level and XP, bag contents, equipped items, mana and existing skills.
- Progression and bag reset on F5; **no save file yet**.
- Detailed acceptance checklist: `docs/tasks/STEP4_ACCEPTANCE.md`.
- Verification now includes the STEP 4 smoke in addition to STEP 0–3 checks.
