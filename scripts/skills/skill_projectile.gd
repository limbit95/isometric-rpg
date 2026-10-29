class_name SkillProjectile2D
extends Node2D
## Bounded, single-hit projectile. Physics query uses the STEP 1 enemy hurtbox mask.

signal target_hit(target: Node2D)

const ENEMY_HURTBOX_MASK: int = 4
const MAX_QUERY_RESULTS: int = 24

var direction: Vector2 = Vector2.RIGHT
var speed: float = 360.0
var max_distance: float = 330.0
var damage: int = 5
var distance_traveled: float = 0.0
var _spent: bool = false


func setup(aim: Vector2, attack_damage: int, projectile_speed: float, travel_limit: float) -> void:
    direction = aim.normalized()
    damage = attack_damage
    speed = projectile_speed
    max_distance = travel_limit


func _physics_process(delta: float) -> void:
    if _spent:
        return
    var step: float = minf(speed * delta, maxf(0.0, max_distance - distance_traveled))
    if step <= 0.0:
        queue_free()
        return
    global_position += direction * step
    distance_traveled += step

    var collision_shape: CircleShape2D = CircleShape2D.new()
    collision_shape.radius = 10.0
    var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
    query.shape = collision_shape
    query.transform = Transform2D(0.0, global_position)
    query.collision_mask = ENEMY_HURTBOX_MASK
    query.collide_with_areas = true
    query.collide_with_bodies = false

    var results: Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(query, MAX_QUERY_RESULTS)
    for result: Dictionary in results:
        var area: Area2D = result.get("collider") as Area2D
        if area == null:
            continue
        var enemy: Node2D = area.get_parent() as Node2D
        if enemy == null or not enemy.is_in_group("enemies") or not enemy.has_method("receive_damage"):
            continue
        if bool(enemy.call("receive_damage", damage)):
            _spent = true
            target_hit.emit(enemy)
            queue_free()
            return

    if distance_traveled >= max_distance:
        queue_free()


func _draw() -> void:
    draw_circle(Vector2.ZERO, 8.0, Color(0.73, 0.40, 1.0, 1.0))
    draw_arc(Vector2.ZERO, 9.0, 0.0, TAU, 18, Color(0.97, 0.88, 1.0, 0.95), 1.5)
