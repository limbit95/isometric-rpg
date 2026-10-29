class_name InventoryComponent
extends Node
## 8 distinct item stacks, with weapon and charm equipment slots.
## Equipping does not consume the item and cannot create copies.

signal inventory_changed
signal equipment_changed

@export_range(1, 30, 1) var max_slots: int = 8

var stacks: Dictionary = {}
var equipment: Dictionary = {"weapon": "", "charm": ""}


func count_item(item_id: String) -> int:
    return int(stacks.get(item_id, 0))


func add_item(item_id: String, amount: int = 1) -> bool:
    var data: ItemData = ItemCatalog.get_item(item_id)
    if data == null or amount <= 0:
        return false
    var previous: int = count_item(item_id)
    if previous == 0 and stacks.size() >= max_slots:
        return false
    if previous + amount > data.max_stack:
        return false
    stacks[item_id] = previous + amount
    inventory_changed.emit()
    return true


func equip_item(item_id: String) -> bool:
    var data: ItemData = ItemCatalog.get_item(item_id)
    if data == null or count_item(item_id) <= 0:
        return false
    if not equipment.has(data.slot):
        return false
    if equipment[data.slot] == item_id:
        return false
    equipment[data.slot] = item_id
    equipment_changed.emit()
    return true


func get_attack_bonus() -> int:
    var weapon: ItemData = ItemCatalog.get_item(str(equipment["weapon"]))
    return weapon.attack_bonus if weapon != null else 0


func get_mana_bonus() -> int:
    var charm: ItemData = ItemCatalog.get_item(str(equipment["charm"]))
    return charm.mana_bonus if charm != null else 0


func inventory_description() -> String:
    var parts: PackedStringArray = PackedStringArray()
    for item_id: String in ["iron_shard", "training_blade", "focus_charm"]:
        var count: int = count_item(item_id)
        if count > 0:
            var data: ItemData = ItemCatalog.get_item(item_id)
            parts.append("%s x%d" % [data.display_name, count])
    return ", ".join(parts) if not parts.is_empty() else "(empty)"
