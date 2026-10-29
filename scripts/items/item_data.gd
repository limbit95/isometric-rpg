class_name ItemData
extends Resource
## Small data-only item definition; equipment statistics are in this resource.

@export var item_id: String = ""
@export var display_name: String = ""
@export_enum("material", "weapon", "charm") var slot: String = "material"
@export_range(1, 99, 1) var max_stack: int = 1
@export_range(0, 50, 1) var attack_bonus: int = 0
@export_range(0, 50, 1) var mana_bonus: int = 0
