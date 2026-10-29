extends SceneTree
## STEP 3: headless cone, projectile, mana and cooldown runtime integration.

func _initialize() -> void:
    call_deferred("_run")


func _tick(frames: int) -> void:
    for i: int in range(frames):
        await physics_frame


func _run() -> void:
    var scene: PackedScene = load("res://scenes/main.tscn") as PackedScene
    if scene == null:
        _fail("Main scene could not be loaded")
        return
    var game: Node2D = scene.instantiate() as Node2D
    root.add_child(game)
    await _tick(4)
    var player: CharacterBody2D = game.get_node("Player") as CharacterBody2D
    var skills: Node2D = player.get_node_or_null("Skills") as Node2D
    var mana: ManaComponent = player.get_node_or_null("ManaComponent") as ManaComponent
    var health: HealthComponent = player.get_node_or_null("HealthComponent") as HealthComponent
    var first: CharacterBody2D = game.get_node("TrainingDummy01") as CharacterBody2D
    var second: CharacterBody2D = game.get_node("TrainingDummy02") as CharacterBody2D
    if skills == null or mana == null or health == null or mana.current_mana != 20:
        _fail("Skills/mana/health setup failed")
        return
    if not InputMap.has_action("skill_cone") or not InputMap.has_action("skill_bolt"):
        _fail("Skill input actions missing")
        return

    # Move two dummies into forward cone, one is slightly off the projectile's ray.
    first.global_position = player.global_position + Vector2(72, 0)
    second.global_position = player.global_position + Vector2(95, 28)
    await _tick(3)

    if not bool(skills.call("cast_cone_at", first.global_position)):
        _fail("Q cone cast rejected")
        return
    if mana.current_mana != 15:
        _fail("Cone must spend exactly 5 MP")
        return
    if bool(skills.call("cast_cone_at", first.global_position)):
        _fail("Q cooldown/queue did not reject immediate repeat")
        return
    await _tick(3)
    var first_health: HealthComponent = first.get_node("HealthComponent") as HealthComponent
    var second_health: HealthComponent = second.get_node("HealthComponent") as HealthComponent
    if first_health.current_health != 1 or second_health.current_health != 1:
        _fail("Q did not damage both targets for 3 HP")
        return

    if not bool(skills.call("cast_bolt_at", first.global_position)):
        _fail("E projectile cast rejected")
        return
    if mana.current_mana != 8:
        _fail("Projectile must spend exactly 7 MP")
        return
    if bool(skills.call("cast_bolt_at", first.global_position)):
        _fail("E cooldown did not reject immediate repeat")
        return
    await _tick(20)
    if is_instance_valid(first) or int(game.get("targets_defeated")) != 1:
        _fail("Projectile did not kill the first target once")
        return
    if second_health.current_health != 1:
        _fail("Projectile hit off-axis target")
        return

    # Regeneration must happen with time (not during cast).
    var mp_before: int = mana.current_mana
    await _tick(125)
    if mana.current_mana <= mp_before:
        _fail("Mana did not regenerate")
        return
    if float(skills.get("bolt_cooldown_remaining")) > 0.0:
        _fail("Bolt cooldown did not expire")
        return

    # Projectile has a bounded travel distance; distant targets cannot be hit.
    second.global_position = player.global_position + Vector2(480, 0)
    await _tick(3)
    if not bool(skills.call("cast_bolt_at", second.global_position)):
        _fail("Second projectile was rejected after cooldown")
        return
    await _tick(85)
    if second_health.current_health != 1:
        _fail("Projectile damaged a target beyond travel limit")
        return
    for child: Node in game.get_children():
        if child is SkillProjectile2D:
            _fail("Projectile did not despawn after max range")
            return

    # Reject invalid costs and cap restoration in the reusable mana pool.
    var unit: ManaComponent = ManaComponent.new()
    unit.max_mana = 10
    game.add_child(unit)
    if unit.try_spend(0) or unit.try_spend(-1) or unit.try_spend(11):
        _fail("Invalid or unaffordable mana spend accepted")
        return
    if not unit.try_spend(9) or unit.current_mana != 1:
        _fail("Mana spending failed")
        return
    if not unit.restore_mana(99) or unit.current_mana != 10:
        _fail("Mana restoration did not cap at max")
        return
    unit.queue_free()

    # Death disables both skills and cancels mana regeneration.
    if not health.take_damage(12) or not health.is_dead():
        _fail("Player death setup failed")
        return
    var death_mp: int = mana.current_mana
    if bool(skills.call("cast_cone_at", second.global_position)):
        _fail("Dead player could cast cone")
        return
    if bool(skills.call("cast_bolt_at", second.global_position)):
        _fail("Dead player could cast projectile")
        return
    await _tick(70)
    if mana.current_mana != death_mp:
        _fail("Mana regenerated after death")
        return

    print("SKILLS_SMOKE_OK | cone=3 multi_hit bolt=5 single_hit range=330 mp=5/7 regen cooldown death")
    quit(0)


func _fail(message: String) -> void:
    push_error("SKILLS_SMOKE_FAIL | " + message)
    quit(1)
