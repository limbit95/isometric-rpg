extends Node2D
## STEP 3 composition root: arena spawns and HUD. Combat/skills are separate components.

const INPUT_BINDINGS: Dictionary = {
    "move_left": [KEY_A, KEY_LEFT],
    "move_right": [KEY_D, KEY_RIGHT],
    "move_up": [KEY_W, KEY_UP],
    "move_down": [KEY_S, KEY_DOWN],
    "skill_cone": [KEY_Q],
    "skill_bolt": [KEY_E],
}
const SPAWN_CELL: Vector2i = Vector2i(10, 10)
const TRAINING_DUMMY_SCENE: PackedScene = preload("res://scenes/enemies/training_dummy.tscn")
const CHASER_SCENE: PackedScene = preload("res://scenes/enemies/chaser_enemy.tscn")
const DUMMY_CELLS: Array[Vector2i] = [
    Vector2i(11, 10),
    Vector2i(14, 12),
    Vector2i(8, 13),
]
const CHASER_CELLS: Array[Vector2i] = [
    Vector2i(17, 3),
    Vector2i(3, 17),
]

var targets_defeated: int = 0
var enemies_defeated: int = 0

@onready var world: TileMapLayer = $World
@onready var player: CharacterBody2D = $Player
@onready var player_health: HealthComponent = $Player/HealthComponent
@onready var player_mana: ManaComponent = $Player/ManaComponent
@onready var player_skills: Node2D = $Player/Skills
@onready var status_label: Label = $HUD/PanelContainer/MarginContainer/VBoxContainer/Status
@onready var player_health_label: Label = $HUD/PanelContainer/MarginContainer/VBoxContainer/PlayerHealth
@onready var player_mana_label: Label = $HUD/PanelContainer/MarginContainer/VBoxContainer/PlayerMana
@onready var skill_status_label: Label = $HUD/PanelContainer/MarginContainer/VBoxContainer/SkillStatus


func _ready() -> void:
    _register_move_inputs()
    player.global_position = world.to_global(world.map_to_local(SPAWN_CELL))
    player_health.health_changed.connect(_on_player_health_changed)
    player_health.died.connect(_on_player_died)
    player_mana.mana_changed.connect(_on_player_mana_changed)
    _spawn_training_targets()
    _spawn_chasers()
    _update_status()
    _on_player_health_changed(player_health.current_health, player_health.max_health)
    _on_player_mana_changed(player_mana.current_mana, player_mana.max_mana)

    
func _process(_delta: float) -> void:
    var q_cd: float = float(player_skills.get("cone_cooldown_remaining"))
    var e_cd: float = float(player_skills.get("bolt_cooldown_remaining"))
    var q_text: String = "Ready" if q_cd <= 0.0 else "%.1fs" % q_cd
    var e_text: String = "Ready" if e_cd <= 0.0 else "%.1fs" % e_cd
    skill_status_label.text = "Q Cone (5 MP): %s  |  E Bolt (7 MP): %s" % [q_text, e_text]


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


func _spawn_chasers() -> void:
    for index: int in range(CHASER_CELLS.size()):
        var enemy: CharacterBody2D = CHASER_SCENE.instantiate() as CharacterBody2D
        enemy.name = "ChaserEnemy%02d" % (index + 1)
        add_child(enemy)
        var spawn_point: Vector2 = world.to_global(world.map_to_local(CHASER_CELLS[index]))
        enemy.global_position = spawn_point
        enemy.call("set_home_position", spawn_point)
        enemy.connect("defeated", _on_enemy_defeated)


func _on_target_defeated() -> void:
    targets_defeated += 1
    _update_status()


func _on_enemy_defeated() -> void:
    enemies_defeated += 1
    _update_status()


func _update_status() -> void:
    status_label.text = "Dummies: %d / %d  |  Enemies: %d / %d" % [
        targets_defeated, DUMMY_CELLS.size(), enemies_defeated, CHASER_CELLS.size()
    ]


func _on_player_health_changed(current: int, maximum: int) -> void:
    player_health_label.text = "Player HP: %d / %d" % [current, maximum]


func _on_player_died() -> void:
    player_health_label.text = "Player HP: 0 — defeated (restart F5)"


func _on_player_mana_changed(current: int, maximum: int) -> void:
    player_mana_label.text = "Player MP: %d / %d  (+1/s)" % [current, maximum]


func _register_move_inputs() -> void:
    for action: String in INPUT_BINDINGS.keys():
        if not InputMap.has_action(action):
            InputMap.add_action(action)
        for keycode in INPUT_BINDINGS[action]:
            var key_event: InputEventKey = InputEventKey.new()
            key_event.physical_keycode = keycode
            if not InputMap.action_has_event(action, key_event):
                InputMap.action_add_event(action, key_event)
