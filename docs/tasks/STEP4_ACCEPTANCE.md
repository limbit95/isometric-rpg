# STEP 4 — progression, loot, inventory and equipment

This is a self-contained prototype for Godot 4.7.2. The feature branch must pass CI and manual gameplay before user-approved main merge.

## Implemented mechanics

- Two chaser enemies each grant 5 XP upon defeat **while the player is alive**. Level 1 -> 2 requires 10 XP; next level 2 -> 3 requires 15 XP. Cap level 10.
- Training dummies provide no XP; each drops one Iron Shard. All drops are deterministic, not random, for repeatable tests.
- ChaserEnemy01 drops **Training Blade**, ChaserEnemy02 drops **Focus Charm**. Loot appears as colored diamond pickups; walk over to collect.
- Bag has 8 distinct stack slots: Iron Shard stacks to 20; Blade and Charm are single-stack.
- Press **1** to equip collected Training Blade (adds +1 to basic attack damage only; Q and E spell values unchanged).
- Press **2** to equip Focus Charm (adds +4 to max MP, 20 -> 24).
- HUD displays level/XP, bag contents, equipment, HP, MP, Q/E cooldowns and defeat counts.
- No loot collection when player dead, no invalid item IDs, no negative quantities or overfilled stacks; item definitions are separate `.tres` resources.

## Playtest

1. Verify existing WASD / LMB / Q / E behavior.
2. Defeat training dummy, see yellow Iron Shard pickup and collect by walking over it.
3. Defeat an orange chaser, verify XP 5 and a blue weapon loot diamond; collect, press 1, then basic attack for 3 damage.
4. Defeat other orange chaser, verify Level 2 / XP 0/15 and purple Charm loot diamond; collect, press 2, verify max MP 24.
5. Verify bag updates when picking up loot. Restart F5 resets everything (no save yet).
6. Verify previous AI, spells and player-death behavior still works.
7. Verify GitHub Actions shows green and user explicitly approves merge.

## Explicit non-goals

No persistence, random drops, skill-based stat scaling, visual inventory grid, drag/drop, consumables, merchants or inventory sorting. These belong to future roadmap iterations.
