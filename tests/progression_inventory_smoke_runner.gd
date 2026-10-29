extends SceneTree
## STEP 4 headless gameplay integration and inventory edge cases.

func _initialize() -> void:
    call_deferred("_run")


func _tick(frames: int) -> void:
    for i: int in range(frames):
        await physics_frame


func _get_pickup(game: Node, item_id: String) -> WorldPickup:
    for child: Node in game.get_children():
        if child is WorldPickup and not child.is_queued_for_deletion():
            var pickup: WorldPickup = child as WorldPickup
            if pickup.item_id == item_id:
                return pickup
    return null


func _run() -> void:
    var packed: PackedScene = load("res://scenes/main.tscn") as PackedScene
    if packed == null:
        _fail("Main scene not loadable")
        return
    var game: Node2D = packed.instantiate() as Node2D
    root.add_child(game)
    await _tick(4)

    var player: CharacterBody2D = game.get_node("Player") as CharacterBody2D
    var health: HealthComponent = player.get_node("HealthComponent") as HealthComponent
    var mana: ManaComponent = player.get_node("ManaComponent") as ManaComponent
    var progress: ProgressionComponent = player.get_node("ProgressionComponent") as ProgressionComponent
    var inventory: InventoryComponent = player.get_node("InventoryComponent") as InventoryComponent
    if progress.level != 1 or progress.experience != 0 or progress.required_experience() != 10:
        _fail("Incorrect initial progression")
        return
    if inventory.stacks.size() != 0 or inventory.get_attack_bonus() != 0 or mana.max_mana != 20:
        _fail("Inventory/equipment not initially empty")
        return
    if inventory.add_item("not_an_item") or inventory.add_item("iron_shard", -1):
        _fail("Unknown item or negative amount accepted")
        return

    # A dummy drops a material but awards no XP.
    var dummy: CharacterBody2D = game.get_node("TrainingDummy01") as CharacterBody2D
    if not bool(dummy.call("receive_damage", 4)):
        _fail("Dummy did not take damage")
        return
    await _tick(3)
    var shard: WorldPickup = _get_pickup(game, "iron_shard")
    if shard == null or progress.experience != 0:
        _fail("Dummy material drop / XP policy incorrect")
        return
    # Real physics body_entered must collect loot when player walks across it.
    player.global_position = shard.global_position
    await _tick(5)
    if inventory.count_item("iron_shard") != 1 or _get_pickup(game, "iron_shard") != null:
        _fail("Collected material missing or still in world")
        return
    if not inventory.add_item("iron_shard", 19) or inventory.add_item("iron_shard"):
        _fail("Stack limit check failed")
        return
    if inventory.equip_item("iron_shard") or inventory.equip_item("focus_charm"):
        _fail("Non-equipment/unowned item was equipped")
        return

    # Each chaser gives 5 XP on death; first drops the weapon.
    var first: CharacterBody2D = game.get_node("ChaserEnemy01") as CharacterBody2D
    if not bool(first.call("receive_damage", 8)):
        _fail("First enemy resisted lethal damage")
        return
    await _tick(3)
    if progress.level != 1 or progress.experience != 5 or int(game.get("enemies_defeated")) != 1:
        _fail("First enemy XP or defeat counter incorrect")
        return
    var blade: WorldPickup = _get_pickup(game, "training_blade")
    if blade == null or not blade.try_collect(player):
        _fail("Weapon drop could not be collected")
        return
    await _tick(2)
    if inventory.count_item("training_blade") != 1 or not inventory.equip_item("training_blade"):
        _fail("Weapon not present/equippable")
        return
    if inventory.get_attack_bonus() != 1 or inventory.equip_item("training_blade"):
        _fail("Weapon bonus or duplicate equipment check failed")
        return

    # New weapon bonus must affect actual player attack without altering base skill damage.
    var second_dummy: CharacterBody2D = game.get_node("TrainingDummy02") as CharacterBody2D
    second_dummy.global_position = player.global_position + Vector2(60, 0)
    await _tick(3)
    var basic: Node2D = player.get_node("Attack") as Node2D
    if not bool(basic.call("queue_attack_at", second_dummy.global_position)):
        _fail("Basic attack rejected after equipping weapon")
        return
    await _tick(3)
    var dummy_health: HealthComponent = second_dummy.get_node("HealthComponent") as HealthComponent
    if dummy_health.current_health != 1:
        _fail("Equipped weapon did not increase melee from 2 to 3")
        return

    # Second chaser triggers one level-up and a charm drop.
    var second: CharacterBody2D = game.get_node("ChaserEnemy02") as CharacterBody2D
    if not bool(second.call("receive_damage", 8)):
        _fail("Second enemy resisted damage")
        return
    await _tick(3)
    if progress.level != 2 or progress.experience != 0 or progress.required_experience() != 15:
        _fail("Second enemy did not grant one level-up")
        return
    var charm: WorldPickup = _get_pickup(game, "focus_charm")
    if charm == null or not charm.try_collect(player):
        _fail("Charm drop could not be collected")
        return
    await _tick(2)
    if not inventory.equip_item("focus_charm") or inventory.get_mana_bonus() != 4 or mana.max_mana != 24:
        _fail("Charm equipment did not raise max mana from 20 to 24")
        return
    if inventory.add_item("focus_charm"):
        _fail("Nonstackable item was duplicated")
        return

    # Rejected pickup must remain available: bag full, invalid owner, dead owner.
    var limited: InventoryComponent = InventoryComponent.new()
    limited.max_slots = 1
    game.add_child(limited)
    if not limited.add_item("iron_shard") or limited.add_item("training_blade"):
        _fail("Distinct inventory slot bound failed")
        return

    if not health.take_damage(12) or not health.is_dead():
        _fail("Player death setup failed")
        return
    var extra: WorldPickup = load("res://scenes/items/world_pickup.tscn").instantiate() as WorldPickup
    extra.configure("iron_shard")
    game.add_child(extra)
    extra.global_position = player.global_position + Vector2(200, 0)
    await _tick(2)
    if extra.try_collect(player) or extra.is_queued_for_deletion():
        _fail("Dead player collected loot")
        return
    if progress.add_experience(0) or progress.add_experience(-10):
        _fail("Nonpositive XP was accepted")
        return

    # XP rollover, max level cap and negative input.
    var isolated: ProgressionComponent = ProgressionComponent.new()
    isolated.max_level = 3
    game.add_child(isolated)
    if not isolated.add_experience(25) or isolated.level != 3 or isolated.experience != 0:
        _fail("XP rollover / max-level cap failed")
        return
    if isolated.add_experience(1):
        _fail("XP accepted beyond max level")
        return

    print("PROGRESSION_INVENTORY_SMOKE_OK | XP level loot pickup stacks equip melee_bonus mana_bonus death")
    quit(0)


func _fail(message: String) -> void:
    push_error("PROGRESSION_INVENTORY_SMOKE_FAIL | " + message)
    quit(1)
