extends SceneTree
## STEP 2 headless runtime state-machine smoke. No graphical test required.

func _initialize() -> void:
    call_deferred("_run")


func _tick(frames: int) -> void:
    for frame: int in range(frames):
        await physics_frame


func _run() -> void:
    var packed: PackedScene = load("res://scenes/main.tscn") as PackedScene
    if packed == null:
        _fail("Main scene did not load")
        return
    var game: Node2D = packed.instantiate() as Node2D
    root.add_child(game)
    await _tick(4)

    var player: CharacterBody2D = game.get_node_or_null("Player") as CharacterBody2D
    var enemy: CharacterBody2D = game.get_node_or_null("ChaserEnemy01") as CharacterBody2D
    if player == null or enemy == null:
        _fail("Expected Player and ChaserEnemy01")
        return
    var player_health: HealthComponent = player.get_node("HealthComponent") as HealthComponent
    var enemy_health: HealthComponent = enemy.get_node("HealthComponent") as HealthComponent
    if player_health.current_health != 12 or enemy_health.current_health != 8:
        _fail("Incorrect initial health")
        return
    var home: Vector2 = enemy.get("home_position")
    if int(enemy.get("state")) != 0:
        _fail("Enemy should be idle when player is far away")
        return

    # Player approaches within detection radius; enemy begins pursuit.
    player.global_position = home + Vector2(-150.0, 0.0)
    await _tick(3)
    if int(enemy.get("state")) != 1:
        _fail("Enemy failed to detect and chase the player")
        return
    var old_distance: float = enemy.global_position.distance_to(player.global_position)
    await _tick(12)
    if enemy.global_position.distance_to(player.global_position) >= old_distance:
        _fail("Enemy failed to move closer")
        return

    # Crossing leash radius cancels chase and returns to spawn.
    enemy.global_position = home + Vector2(-350.0, 0.0)
    await _tick(2)
    if int(enemy.get("state")) != 4:
        _fail("Enemy did not enter RETURN outside leash")
        return
    player.global_position = home + Vector2(-500.0, 0.0)
    enemy.global_position = home + Vector2(-4.0, 0.0)
    await _tick(2)
    if int(enemy.get("state")) != 0:
        _fail("Enemy did not become idle at home")
        return

    # Telegraph must allow a moving player to dodge before hit resolves.
    player.global_position = home + Vector2(-28.0, 0.0)
    await _tick(4)
    if int(enemy.get("state")) != 2:
        _fail("Enemy did not begin WINDUP within attack range")
        return
    player.global_position = home + Vector2(-160.0, 0.0)
    await _tick(26)
    if player_health.current_health != 12:
        _fail("Out-of-range player was hit after dodging")
        return

    # Re-enter attack range; cooldown suppresses immediate repeats.
    player.global_position = enemy.global_position + Vector2(-27.0, 0.0)
    var hits_seen: int = 0
    for frame: int in range(125):
        await physics_frame
        if player_health.current_health < 12:
            hits_seen = 12 - player_health.current_health
            break
    if hits_seen != 2:
        _fail("Enemy did not apply exactly 2 damage on hit")
        return
    await _tick(18)
    if player_health.current_health != 10:
        _fail("Enemy attacked twice during cooldown")
        return

    # Existing STEP 1 player melee must damage the new enemy hurtbox.
    var melee: Node2D = player.get_node("Attack") as Node2D
    if not bool(melee.call("queue_attack_at", enemy.global_position)):
        _fail("Player attack was rejected against moving enemy")
        return
    await _tick(3)
    if enemy_health.current_health != 6:
        _fail("Player melee did not hit the new enemy for 2 damage")
        return

    # Health death must block player input and enemy attacks.
    if not player_health.take_damage(10) or not player_health.is_dead():
        _fail("Player death state failed")
        return
    if bool(player.get_node("Attack").call("queue_attack_at", enemy.global_position)):
        _fail("Dead player can still attack")
        return
    Input.action_press("move_right")
    await _tick(3)
    Input.action_release("move_right")
    if not player.velocity.is_zero_approx():
        _fail("Dead player still has movement velocity")
        return
    if int(enemy.get("state")) != 4:
        _fail("Enemy did not return after player death")
        return

    # Enemy death is idempotent; defeat count is one.
    if not bool(enemy.call("receive_damage", 6)):
        _fail("Enemy did not receive lethal damage")
        return
    await _tick(3)
    if is_instance_valid(enemy):
        _fail("Enemy did not despawn on death")
        return
    if int(game.get("enemies_defeated")) != 1:
        _fail("Enemy defeat count is not exactly one")
        return

    print("ENEMY_AI_SMOKE_OK | idle chase leash return dodge cooldown player_death enemy_death")
    quit(0)


func _fail(message: String) -> void:
    Input.action_release("move_right")
    push_error("ENEMY_AI_SMOKE_FAIL | " + message)
    quit(1)
