extends Node2D
## One mouse click queues one melee attack. Physics query resolves hurtboxes.

signal attack_performed(hit_count: int)

const HURTBOX_MASK: int = 4
const MAX_QUERY_RESULTS: int = 24

@export_range(1, 100, 1) var attack_damage: int = 2
@export_range(16.0, 256.0, 1.0) var attack_range: float = 84.0
@export_range(20.0, 180.0, 1.0) var attack_arc_degrees: float = 110.0
@export_range(0.1, 3.0, 0.05) var attack_cooldown: float = 0.4

var _remaining_cooldown: float = 0.0
var _queued_direction: Vector2 = Vector2.ZERO
var _last_direction: Vector2 = Vector2.RIGHT
var _visual_remaining: float = 0.0


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var click: InputEventMouseButton = event as InputEventMouseButton
        if click.button_index == MOUSE_BUTTON_LEFT and click.pressed:
            if queue_attack_at(get_global_mouse_position()):
                get_viewport().set_input_as_handled()


func queue_attack_at(world_point: Vector2) -> bool:
    if _remaining_cooldown > 0.0 or not _queued_direction.is_zero_approx():
        return false
    var aim: Vector2 = world_point - global_position
    if aim.length_squared() < 0.01:
        return false
    _queued_direction = aim.normalized()
    return true


func _physics_process(delta: float) -> void:
    _remaining_cooldown = maxf(0.0, _remaining_cooldown - delta)
    if _visual_remaining > 0.0:
        _visual_remaining = maxf(0.0, _visual_remaining - delta)
        queue_redraw()
    if not _queued_direction.is_zero_approx():
        var aim: Vector2 = _queued_direction
        _queued_direction = Vector2.ZERO
        _perform_attack(aim)


func _perform_attack(aim: Vector2) -> void:
    _remaining_cooldown = attack_cooldown
    _last_direction = aim
    _visual_remaining = 0.13
    queue_redraw()

    var strike: CircleShape2D = CircleShape2D.new()
    strike.radius = attack_range
    var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
    query.shape = strike
    query.transform = Transform2D(0.0, global_position)
    query.collision_mask = HURTBOX_MASK
    query.collide_with_areas = true
    query.collide_with_bodies = false

    var hits: int = 0
    var hit_targets: Dictionary = {}
    var overlaps: Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(query, MAX_QUERY_RESULTS)
    var min_dot: float = cos(deg_to_rad(attack_arc_degrees * 0.5))
    for result: Dictionary in overlaps:
        var area: Area2D = result.get("collider") as Area2D
        if area == null:
            continue
        var target: Node2D = area.get_parent() as Node2D
        if target == null or not target.is_in_group("enemies") or not target.has_method("receive_damage"):
            continue
        if hit_targets.has(target.get_instance_id()):
            continue
        var to_target: Vector2 = target.global_position - global_position
        if not to_target.is_zero_approx() and to_target.normalized().dot(aim) < min_dot:
            continue
        hit_targets[target.get_instance_id()] = true
        if bool(target.call("receive_damage", attack_damage)):
            hits += 1
    attack_performed.emit(hits)


func _draw() -> void:
    if _visual_remaining <= 0.0:
        return
    var angle: float = _last_direction.angle()
    var half_arc: float = deg_to_rad(attack_arc_degrees * 0.5)
    var wedge: PackedVector2Array = PackedVector2Array([Vector2.ZERO])
    for index: int in range(13):
        var direction_angle: float = angle - half_arc + (2.0 * half_arc * float(index) / 12.0)
        wedge.append(Vector2.from_angle(direction_angle) * attack_range)
    draw_colored_polygon(wedge, Color(1.0, 0.82, 0.26, 0.25))
