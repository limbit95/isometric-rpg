extends Node2D
## STEP 3: two independent skills, mana costs and cooldowns.
## Q = cone, E = projectile. STEP 1 basic attack remains separate.

signal skill_cast(skill_name: String)

const HURTBOX_MASK: int = 4
const MAX_QUERY_RESULTS: int = 24

@export_range(1, 50, 1) var cone_damage: int = 3
@export_range(40.0, 250.0, 1.0) var cone_range: float = 126.0
@export_range(30.0, 180.0, 1.0) var cone_arc_degrees: float = 100.0
@export_range(1, 50, 1) var cone_mana_cost: int = 5
@export_range(0.1, 10.0, 0.1) var cone_cooldown: float = 1.3

@export_range(1, 50, 1) var bolt_damage: int = 5
@export_range(40.0, 700.0, 1.0) var bolt_range: float = 330.0
@export_range(40.0, 800.0, 1.0) var bolt_speed: float = 360.0
@export_range(1, 50, 1) var bolt_mana_cost: int = 7
@export_range(0.1, 10.0, 0.1) var bolt_cooldown: float = 1.8

var cone_cooldown_remaining: float = 0.0
var bolt_cooldown_remaining: float = 0.0
var _queued_cone: Vector2 = Vector2.ZERO
var _cone_visual_remaining: float = 0.0
var _last_cone_direction: Vector2 = Vector2.RIGHT

@onready var health: HealthComponent = $"../HealthComponent"
@onready var mana: ManaComponent = $"../ManaComponent"


func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_echo():
        return
    if event.is_action_pressed("skill_cone"):
        if cast_cone_at(get_global_mouse_position()):
            get_viewport().set_input_as_handled()
    elif event.is_action_pressed("skill_bolt"):
        if cast_bolt_at(get_global_mouse_position()):
            get_viewport().set_input_as_handled()


func _can_cast(cost: int, remaining: float) -> bool:
    return not health.is_dead() and remaining <= 0.0 and mana.current_mana >= cost


func cast_cone_at(world_point: Vector2) -> bool:
    if not _can_cast(cone_mana_cost, cone_cooldown_remaining):
        return false
    if not _queued_cone.is_zero_approx():
        return false
    var aim: Vector2 = world_point - global_position
    if aim.length_squared() <= 0.01:
        return false
    if not mana.try_spend(cone_mana_cost):
        return false
    cone_cooldown_remaining = cone_cooldown
    _queued_cone = aim.normalized()
    skill_cast.emit("cone")
    return true


func cast_bolt_at(world_point: Vector2) -> bool:
    if not _can_cast(bolt_mana_cost, bolt_cooldown_remaining):
        return false
    var aim: Vector2 = world_point - global_position
    if aim.length_squared() <= 0.01:
        return false
    if not mana.try_spend(bolt_mana_cost):
        return false
    bolt_cooldown_remaining = bolt_cooldown
    var projectile: SkillProjectile2D = SkillProjectile2D.new()
    projectile.setup(aim, bolt_damage, bolt_speed, bolt_range)
    get_parent().get_parent().add_child(projectile)
    projectile.global_position = global_position + aim.normalized() * 22.0
    skill_cast.emit("bolt")
    return true


func _physics_process(delta: float) -> void:
    cone_cooldown_remaining = maxf(0.0, cone_cooldown_remaining - delta)
    bolt_cooldown_remaining = maxf(0.0, bolt_cooldown_remaining - delta)
    if _cone_visual_remaining > 0.0:
        _cone_visual_remaining = maxf(0.0, _cone_visual_remaining - delta)
        queue_redraw()
    if not _queued_cone.is_zero_approx():
        var direction: Vector2 = _queued_cone
        _queued_cone = Vector2.ZERO
        _perform_cone(direction)


func _perform_cone(aim: Vector2) -> void:
    _last_cone_direction = aim
    _cone_visual_remaining = 0.18
    queue_redraw()
    var shape: CircleShape2D = CircleShape2D.new()
    shape.radius = cone_range
    var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
    query.shape = shape
    query.transform = Transform2D(0.0, global_position)
    query.collision_mask = HURTBOX_MASK
    query.collide_with_areas = true
    query.collide_with_bodies = false
    var results: Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(query, MAX_QUERY_RESULTS)
    var min_dot: float = cos(deg_to_rad(cone_arc_degrees * 0.5))
    var seen: Dictionary = {}
    for result: Dictionary in results:
        var area: Area2D = result.get("collider") as Area2D
        if area == null:
            continue
        var target: Node2D = area.get_parent() as Node2D
        if target == null or not target.is_in_group("enemies") or not target.has_method("receive_damage"):
            continue
        var target_id: int = target.get_instance_id()
        if seen.has(target_id):
            continue
        var to_target: Vector2 = target.global_position - global_position
        if to_target.length() > cone_range:
            continue
        if not to_target.is_zero_approx() and to_target.normalized().dot(aim) < min_dot:
            continue
        seen[target_id] = true
        target.call("receive_damage", cone_damage)


func _draw() -> void:
    if _cone_visual_remaining <= 0.0:
        return
    var center_angle: float = _last_cone_direction.angle()
    var half_arc: float = deg_to_rad(cone_arc_degrees * 0.5)
    var vertices: PackedVector2Array = PackedVector2Array([Vector2.ZERO])
    for i: int in range(17):
        var angle: float = center_angle - half_arc + 2.0 * half_arc * float(i) / 16.0
        vertices.append(Vector2.from_angle(angle) * cone_range)
    draw_colored_polygon(vertices, Color(0.27, 0.97, 0.81, 0.32))
