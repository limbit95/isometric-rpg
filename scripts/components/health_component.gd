class_name HealthComponent
extends Node
## Reusable health contract. Positive damage only; death fires once.

signal health_changed(current_health: int, maximum_health: int)
signal died

@export_range(1, 9999, 1) var max_health: int = 4
var current_health: int = 0


func _ready() -> void:
    current_health = max_health
    health_changed.emit(current_health, max_health)


func take_damage(amount: int) -> bool:
    if amount <= 0 or is_dead():
        return false
    current_health = maxi(0, current_health - amount)
    health_changed.emit(current_health, max_health)
    if current_health == 0:
        died.emit()
    return true


func is_dead() -> bool:
    return current_health <= 0


func get_current_health() -> int:
    return current_health
