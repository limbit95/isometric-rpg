class_name ManaComponent
extends Node
## STEP 3 reusable integer mana pool. Regen stops after the player's death.

signal mana_changed(current_mana: int, maximum_mana: int)

@export_range(1, 999, 1) var max_mana: int = 20
@export_range(0.1, 10.0, 0.1) var regen_interval: float = 1.0
@export_range(1, 10, 1) var regen_amount: int = 1

var current_mana: int = 0
var _regen_elapsed: float = 0.0


func _ready() -> void:
    current_mana = max_mana
    mana_changed.emit(current_mana, max_mana)


func _physics_process(delta: float) -> void:
    var health: HealthComponent = get_parent().get_node_or_null("HealthComponent") as HealthComponent
    if health != null and health.is_dead():
        return
    if current_mana >= max_mana:
        _regen_elapsed = 0.0
        return
    _regen_elapsed += delta
    while _regen_elapsed >= regen_interval and current_mana < max_mana:
        _regen_elapsed -= regen_interval
        restore_mana(regen_amount)


func try_spend(amount: int) -> bool:
    if amount <= 0 or amount > current_mana:
        return false
    current_mana -= amount
    mana_changed.emit(current_mana, max_mana)
    return true


func restore_mana(amount: int) -> bool:
    if amount <= 0 or current_mana >= max_mana:
        return false
    current_mana = mini(max_mana, current_mana + amount)
    mana_changed.emit(current_mana, max_mana)
    return true
