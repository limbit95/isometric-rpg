# STEP 3 — active skills, mana, cooldowns

Status: development branch; PR and play test required before merge.

## Player controls

- WASD / arrow keys: move, left click: STEP 1 basic attack, Esc: quit.
- Point mouse in the intended direction, press **Q** for a turquoise cone: 126px, 100° arc, damage 3 to every enemy in the cone, 5 MP, 1.3s cooldown.
- Point mouse and press **E** for a purple forward-moving bolt: damage 5 to first enemy, speed 360px/s, max travel 330px after a 22px muzzle offset, 7 MP, 1.8s cooldown.
- The two cooldowns are independent and do not gate the basic melee attack.

## Mana and UI

- ManaComponent owns max 20 MP; after spending, regenerate +1 MP each second (while alive). All spends must be positive, affordable, and atomic.
- Main HUD shows current HP, MP, and remaining cooldowns (Ready or seconds).
- Dead player cannot cast either skill, and mana regen stops. Restart F5 resets the arena.

## Acceptance gates

1. STEP0, STEP1 and STEP2 regression tests remain green.
2. New STEP3 Python contract tests pass.
3. Godot headless runtime verifies cone multi-target damage, projectile single-target damage, travel cap, independent cooldowns, mana spend/regeneration, dead-player rejection.
4. Manual Godot graphical play: Q damages dummies in front, E projectile hits one target, HP/MP bars and cooldown text react, enemies still chase/attack.
5. Play test and explicit user approval required before any main merge.

## Limitations

- Placeholder effects (translucent cone polygon and purple projectile circle), no sound, skill animation, status effects or talent tree.
- Simplified flat arena, no wall obstruction checks for projectiles. Wall-aware collision comes with map obstacles.
- Skill parameters are editable exports rather than data-driven resources; external skill definitions can be added after system behavior is stable.
