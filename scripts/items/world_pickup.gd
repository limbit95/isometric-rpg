class_name WorldPickup
extends Area2D
## Loot pickup on player body entering. Collected only if inventory accepts it.

signal collected(item_id: String)

var item_id: String = ""

@onready var label: Label = $Label
@onready var visual: Polygon2D = $Visual


func _ready() -> void:
    body_entered.connect(_on_body_entered)
    _refresh_visual()


func configure(value: String) -> void:
    item_id = value
    if is_node_ready():
        _refresh_visual()


func _refresh_visual() -> void:
    label.text = "?"
    visual.color = Color(0.96, 0.80, 0.26, 0.95)
    if item_id == "training_blade":
        label.text = "W"
        visual.color = Color(0.43, 0.76, 1.0, 0.95)
    elif item_id == "focus_charm":
        label.text = "C"
        visual.color = Color(0.85, 0.49, 1.0, 0.95)
    elif item_id == "iron_shard":
        label.text = "I"


func _on_body_entered(body: Node2D) -> void:
    try_collect(body)


func try_collect(body: Node2D) -> bool:
    if not is_inside_tree() or not is_instance_valid(body):
        return false
    var health: HealthComponent = body.get_node_or_null("HealthComponent") as HealthComponent
    var inventory: InventoryComponent = body.get_node_or_null("InventoryComponent") as InventoryComponent
    if health == null or health.is_dead() or inventory == null:
        return false
    if not inventory.add_item(item_id):
        return false
    collected.emit(item_id)
    monitoring = false
    queue_free()
    return true
