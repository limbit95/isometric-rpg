extends Node2D
## STEP 1 composition root: input bindings, spawns, and training HUD.
## Combat resolution belongs to Player/Attack and HealthComponent.

const INPUT_BINDINGS: Dictionary = {
    "move_left": [KEY_A, KEY_LEFT],
    "move_right": [KEY_D, KEY_RIGHT],
    "move_up": [KEY_W, KEY_UP],
    "move_down": [KEY_S, KEY_DOWN],
}
const SPAWN_CELL: Vector2i = Vector2i(10, 10)
const TRAINING_DUMMY_SCENE: PackedScene = preload("res://scenes/enemies/training_dummy.tscn")
const DUMMY_CELLS: Array[Vector2i] = [
    Vector2i(11, 10),
    Vector2i(14, 12),
    Vector2i(8, 13),
]

var targets_defeated: int = 0

@onready var world: TileMapLayer = $World
@onready var player: CharacterBody2D = $Player
@onready var status_label: Label = $HUD/PanelContainer/MarginContainer/VBoxContainer/Status


func _ready() -> void:
    _register_move_inputs()
    player.global_position = world.to_global(world.map_to_local(SPAWN_CELL))
    _spawn_training_targets()
    _update_status()


func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()
        get_tree().quit()


func _spawn_training_targets() -> void:
    for index: int in range(DUMMY_CELLS.size()):
        var dummy: CharacterBody2D = TRAINING_DUMMY_SCENE.instantiate() as CharacterBody2D
        dummy.name = "TrainingDummy%02d" % (index + 1)
        add_child(dummy)
        dummy.global_position = world.to_global(world.map_to_local(DUMMY_CELLS[index]))
        dummy.connect("defeated", _on_target_defeated)


func _on_target_defeated() -> void:
    targets_defeated += 1
    _update_status()


func _update_status() -> void:
    status_label.text = "Training targets defeated: %d / %d" % [targets_defeated, DUMMY_CELLS.size()]


func _register_move_inputs() -> void:
    for action: String in INPUT_BINDINGS.keys():
        if not InputMap.has_action(action):
            InputMap.add_action(action)
        for keycode in INPUT_BINDINGS[action]:
            var key_event: InputEventKey = InputEventKey.new()
            key_event.physical_keycode = keycode
            if not InputMap.action_has_event(action, key_event):
                InputMap.action_add_event(action, key_event)
