extends Node2D
## STEP 0 composition root: owns input bindings and the start position.
## Keep gameplay systems separate; do not implement combat here.

const INPUT_BINDINGS: Dictionary = {
    "move_left": [KEY_A, KEY_LEFT],
    "move_right": [KEY_D, KEY_RIGHT],
    "move_up": [KEY_W, KEY_UP],
    "move_down": [KEY_S, KEY_DOWN],
}
const SPAWN_CELL: Vector2i = Vector2i(10, 10)

@onready var world: TileMapLayer = $World
@onready var player: CharacterBody2D = $Player


func _ready() -> void:
    _register_move_inputs()
    player.global_position = world.to_global(world.map_to_local(SPAWN_CELL))


func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()
        get_tree().quit()


func _register_move_inputs() -> void:
    for action: String in INPUT_BINDINGS.keys():
        if not InputMap.has_action(action):
            InputMap.add_action(action)
        for keycode in INPUT_BINDINGS[action]:
            var key_event: InputEventKey = InputEventKey.new()
            key_event.physical_keycode = keycode
            if not InputMap.action_has_event(action, key_event):
                InputMap.action_add_event(action, key_event)
