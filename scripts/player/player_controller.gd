extends CharacterBody2D
## WASD movement preserved. Cannot move after player death.

@export_range(50.0, 500.0, 10.0) var move_speed: float = 180.0

@onready var world: TileMapLayer = $"../World"
@onready var health: HealthComponent = $HealthComponent


func _physics_process(delta: float) -> void:
    if health.is_dead():
        velocity = Vector2.ZERO
        return

    var direction: Vector2 = Input.get_vector(
        "move_left", "move_right", "move_up", "move_down"
    )
    velocity = direction * move_speed

    if velocity.is_zero_approx():
        move_and_slide()
        return

    var target: Vector2 = global_position + velocity * delta
    if not world.has_method("has_ground_at") or not world.call("has_ground_at", target):
        velocity = Vector2.ZERO

    move_and_slide()
