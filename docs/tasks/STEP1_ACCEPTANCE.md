# STEP 1 — Basic melee / dummy combat

Status: IMPLEMENTED ON FEATURE BRANCH; NOT MERGED. Godot CI and visual play-test required.

## Scope and behaviors

- Keep the STEP 0 isometric floor, camera, WASD controls and existing movement script.
- Left mouse click queues one directional melee strike.
- A physics shape query intersects enemy Area2D hurtboxes on collision layer 4, within 84 pixels and a 110-degree arc.
- Damage: 2 HP. Cooldown: 0.4 seconds. No automatic repeats on held click.
- Three stationary training targets start at 4 HP and can be defeated in two successful strikes.
- A separate HealthComponent owns damage validation, health-change signals and a one-time death transition.
- Training dummy owns health bar update, emits defeated and is removed on death.
- HUD displays defeat count; brief translucent melee wedge previews the attack region.

## Acceptance gates

1. Python project tests pass (old STEP 0 plus new STEP 1).
2. Godot 4.7.2 headless import and old isometric smoke pass.
3. Godot headless combat smoke passes: damage=2, cooldown, out-of-range isolation, target death, damage validation.
4. In graphical F5 gameplay, WASD still works and left-click near a red dummy causes visible melee wedge and health loss. Two hits kill a dummy.
5. Dummy does not pursue or counterattack; enemy AI is intentionally outside STEP 1.
6. GitHub Actions is green; only then request human approval to merge.

## Caveats

- Early prototype uses placeholder sprites, no hit/attack animation or audio.
- Pixel-range and wedge are tested at sample positions; visual game feel requires human validation.
- Does not introduce weapon equipment, stats, loot, saves or persistence.

## Rollback

Close PR without merging or reset only the feature branch. Main remains unchanged.
