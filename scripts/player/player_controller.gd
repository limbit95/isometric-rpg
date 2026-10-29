extends CharacterBody2D
## A keyboard-movable placeholder player. No combat in STEP 0.

@export_range(50.0, 500.0, 10.0) var move_speed: float = 180.0

@onready var world: TileMapLayer = $"../World"


func _physics_process(delta: float) -> void:
    var direction: Vector2 = Input.get_vector(
        "move_left", "move_right", "move_up", "move_down"
    )
    velocity = direction * move_speed

    if velocity.is_zero_approx():
        move_and_slide()
        return

    # Cheap STEP 0 bounds check, not a substitute for physical wall collisions.
    var target: Vector2 = global_position + velocity * delta
    if not world.has_method("has_ground_at") or not world.call("has_ground_at", target):
        velocity = Vector2.ZERO

    move_and_slide()
