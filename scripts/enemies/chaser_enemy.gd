extends CharacterBody2D
## STEP 2: deterministic flat-arena enemy state machine.
## No pathfinding on obstacle maps yet; leave room for NavigationAgent2D later.

signal defeated

enum State { IDLE, CHASE, WINDUP, RECOVER, RETURN, DEAD }

@export_range(40.0, 300.0, 1.0) var move_speed: float = 88.0
@export_range(50.0, 600.0, 1.0) var detection_radius: float = 215.0
@export_range(50.0, 750.0, 1.0) var leash_radius: float = 330.0
@export_range(15.0, 120.0, 1.0) var attack_range: float = 43.0
@export_range(0.05, 2.0, 0.01) var attack_windup: float = 0.28
@export_range(0.1, 4.0, 0.05) var attack_cooldown: float = 1.15
@export_range(1, 100, 1) var attack_damage: int = 2

var state: State = State.IDLE
var home_position: Vector2 = Vector2.ZERO
var _windup_remaining: float = 0.0
var _cooldown_remaining: float = 0.0
var _death_handled: bool = false

@onready var player: CharacterBody2D = get_node_or_null("../Player") as CharacterBody2D
@onready var world: TileMapLayer = get_node_or_null("../World") as TileMapLayer
@onready var health: HealthComponent = $HealthComponent
@onready var health_bar: ProgressBar = $HealthBar
@onready var warning: Polygon2D = $Warning


func _ready() -> void:
    home_position = global_position
    health.health_changed.connect(_on_health_changed)
    health.died.connect(_on_died)
    _on_health_changed(health.current_health, health.max_health)


func set_home_position(value: Vector2) -> void:
    home_position = value


func receive_damage(amount: int) -> bool:
    var accepted: bool = health.take_damage(amount)
    if accepted and state == State.IDLE and _target_alive():
        state = State.CHASE
    return accepted


func _target_alive() -> bool:
    if not is_instance_valid(player):
        return false
    var target_health: HealthComponent = player.get_node_or_null("HealthComponent") as HealthComponent
    return target_health != null and not target_health.is_dead()


func _physics_process(delta: float) -> void:
    if state == State.DEAD:
        velocity = Vector2.ZERO
        return
    _cooldown_remaining = maxf(0.0, _cooldown_remaining - delta)
    velocity = Vector2.ZERO
    warning.visible = state == State.WINDUP

    if not _target_alive():
        _start_return()
    elif global_position.distance_to(home_position) > leash_radius:
        _start_return()
    else:
        match state:
            State.IDLE:
                if global_position.distance_to(player.global_position) <= detection_radius:
                    state = State.CHASE
            State.CHASE:
                _update_chase(delta)
            State.WINDUP:
                _update_windup(delta)
            State.RECOVER:
                if global_position.distance_to(player.global_position) > attack_range:
                    state = State.CHASE
                elif _cooldown_remaining <= 0.0:
                    _start_windup()
            State.RETURN:
                _update_return(delta)
            State.DEAD:
                pass

    if state == State.RETURN:
        _update_return(delta)


func _update_chase(delta: float) -> void:
    var distance: float = global_position.distance_to(player.global_position)
    if distance <= attack_range:
        if _cooldown_remaining <= 0.0:
            _start_windup()
        else:
            state = State.RECOVER
        return
    _move_towards(player.global_position, delta)


func _start_windup() -> void:
    state = State.WINDUP
    _windup_remaining = attack_windup
    warning.visible = true


func _update_windup(delta: float) -> void:
    _windup_remaining = maxf(0.0, _windup_remaining - delta)
    if _windup_remaining > 0.0:
        return
    warning.visible = false
    state = State.RECOVER
    _cooldown_remaining = attack_cooldown
    if _target_alive() and global_position.distance_to(player.global_position) <= attack_range:
        var target_health: HealthComponent = player.get_node("HealthComponent") as HealthComponent
        target_health.take_damage(attack_damage)


func _start_return() -> void:
    state = State.RETURN
    _windup_remaining = 0.0
    warning.visible = false


func _update_return(delta: float) -> void:
    if global_position.distance_to(home_position) <= 6.0:
        global_position = home_position
        velocity = Vector2.ZERO
        state = State.IDLE
        return
    _move_towards(home_position, delta)


func _move_towards(destination: Vector2, delta: float) -> void:
    var delta_position: Vector2 = destination - global_position
    if delta_position.length() < 2.0:
        return
    velocity = delta_position.normalized() * move_speed
    var next_position: Vector2 = global_position + velocity * delta
    if world != null and world.has_method("has_ground_at"):
        if not bool(world.call("has_ground_at", next_position)):
            velocity = Vector2.ZERO
            return
    move_and_slide()


func _on_health_changed(current: int, maximum: int) -> void:
    health_bar.max_value = maximum
    health_bar.value = current


func _on_died() -> void:
    if _death_handled:
        return
    _death_handled = true
    state = State.DEAD
    warning.visible = false
    velocity = Vector2.ZERO
    defeated.emit()
    queue_free()
