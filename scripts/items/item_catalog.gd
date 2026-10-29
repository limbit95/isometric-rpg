class_name ItemCatalog
extends RefCounted
## Explicit allowlist for loot and inventory; never load arbitrary user paths.

const IRON_SHARD = preload("res://data/items/iron_shard.tres")
const TRAINING_BLADE = preload("res://data/items/training_blade.tres")
const FOCUS_CHARM = preload("res://data/items/focus_charm.tres")


static func get_item(item_id: String) -> ItemData:
    match item_id:
        "iron_shard":
            return IRON_SHARD
        "training_blade":
            return TRAINING_BLADE
        "focus_charm":
            return FOCUS_CHARM
    return null
