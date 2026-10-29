# STEP 2 — enemy AI and player health (prototype flat arena)

Status: feature branch, PR review and hands-on gameplay pending.

## Features and intentionally limited scope

- New independent orange ChaserEnemy scene with 8 HP / 2 damage.
- States: IDLE → CHASE → WINDUP → RECOVER → RETURN and DEAD.
- Detection radius 215px, home leash 330px, attack range 43px; windup 0.28s, cooldown 1.15s.
- Player starts at 12 HP, HP displayed in the existing HUD, death stops WASD and melee attack.
- Enemies lose interest and return to spawn if the player dies or they exceed leash.
- Windup is visually telegraphed with a brief red area indicator; moving out of range before the hit resolves avoids damage.
- One-time death and defeat count; HealthComponent from STEP 1 reused unchanged.
- Original three stationary STEP 1 training dummies retained to ensure regression coverage.
- Enemy movement is direct line pursuit suitable for the current empty isometric tile arena; **obstacles / navigation meshes / pathfinding are not solved yet**.

## Verification gate

1. Python project contract tests succeed (STEP0 + STEP1 + STEP2).
2. Godot headless import, STEP0 map smoke, STEP1 combat smoke, STEP2 AI runtime smoke all succeed.
3. Manual Godot F5 check: approach orange enemy near far left/right map corners, see pursuit and telegraphed attack; HP decreases; step out of range to dodge; retreat until enemy returns.
4. Player death disables movement/attacks; enemy death increments HUD.
5. Only merge after CI success, user play check and explicit merge approval.

## Limitations

- Player has no post-death restart button. Press F5 to restart.
- Placeholder sprite and polygon attack warning only; no animation or audio.
- Collision with scenery and advanced navigation deferred.
- Enemy AI does not use a multithreaded agent or backend services.
