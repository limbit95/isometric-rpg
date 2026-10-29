extends SceneTree
## STEP 1 deterministic combat smoke. Run with Godot --headless --script.

func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    var packed: PackedScene = load("res://scenes/main.tscn") as PackedScene
    if packed == null:
        _fail("Could not load main scene")
        return
    var game: Node2D = packed.instantiate() as Node2D
    root.add_child(game)
    await process_frame
    await physics_frame
    await physics_frame

    var player: CharacterBody2D = game.get_node_or_null("Player") as CharacterBody2D
    var first: CharacterBody2D = game.get_node_or_null("TrainingDummy01") as CharacterBody2D
    var second: CharacterBody2D = game.get_node_or_null("TrainingDummy02") as CharacterBody2D
    if player == null or first == null or second == null:
        _fail("Player or training dummy was not spawned")
        return
    var attack: Node2D = player.get_node_or_null("Attack") as Node2D
    if attack == null:
        _fail("Attack component is missing")
        return
    var first_health: HealthComponent = first.get_node("HealthComponent") as HealthComponent
    var second_health: HealthComponent = second.get_node("HealthComponent") as HealthComponent
    if first_health == null or second_health == null:
        _fail("Health component is missing")
        return
    var before: int = first_health.current_health
    if player.global_position.distance_to(first.global_position) > 84.0:
        _fail("First dummy should be reachable at spawn")
        return

    if not bool(attack.call("queue_attack_at", first.global_position)):
        _fail("First attack was rejected")
        return
    await physics_frame
    await physics_frame
    if first_health.current_health != before - 2:
        _fail("Basic attack did not deal exactly 2 damage")
        return
    if bool(attack.call("queue_attack_at", first.global_position)):
        _fail("Attack cooldown did not block a second click")
        return
    if second_health.current_health != second_health.max_health:
        _fail("Out-of-range dummy took damage")
        return

    for frame: int in range(35):
        await physics_frame
    if not bool(attack.call("queue_attack_at", first.global_position)):
        _fail("Attack did not recover after cooldown")
        return
    await physics_frame
    await physics_frame
    if is_instance_valid(first):
        _fail("Dead dummy was not removed")
        return
    if int(game.get("targets_defeated")) != 1:
        _fail("Defeat counter is incorrect")
        return

    var unit: HealthComponent = HealthComponent.new()
    unit.max_health = 3
    game.add_child(unit)
    if unit.take_damage(0) or unit.take_damage(-10):
        _fail("Zero or negative damage was accepted")
        return
    if not unit.take_damage(3) or not unit.is_dead():
        _fail("Damage or death state failed")
        return
    if unit.take_damage(1) or unit.current_health != 0:
        _fail("Dead health component accepted additional damage")
        return

    print("COMBAT_SMOKE_OK | melee=2 cooldown=yes out_of_range=safe death=yes")
    quit(0)


func _fail(message: String) -> void:
    push_error("COMBAT_SMOKE_FAIL | " + message)
    quit(1)
