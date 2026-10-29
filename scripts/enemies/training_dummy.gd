extends CharacterBody2D
## Static STEP 1 target. AI and counterattacks intentionally deferred.

signal defeated

@onready var health: HealthComponent = $HealthComponent
@onready var health_bar: ProgressBar = $HealthBar


func _ready() -> void:
    health.health_changed.connect(_on_health_changed)
    health.died.connect(_on_died)
    _on_health_changed(health.current_health, health.max_health)


func receive_damage(amount: int) -> bool:
    return health.take_damage(amount)


func _on_health_changed(current: int, maximum: int) -> void:
    health_bar.max_value = maximum
    health_bar.value = current


func _on_died() -> void:
    defeated.emit()
    queue_free()
