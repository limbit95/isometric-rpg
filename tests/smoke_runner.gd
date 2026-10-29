extends SceneTree
## CI-safe runtime smoke test. Execute with --headless --script.
## Exit 0 on success, 1 on failure; no graphics/window required.


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    var main_scene: PackedScene = load("res://scenes/main.tscn") as PackedScene
    if main_scene == null:
        _fail("Cannot load main scene")
        return

    var game: Node = main_scene.instantiate()
    root.add_child(game)
    await process_frame

    var world: TileMapLayer = game.get_node_or_null("World") as TileMapLayer
    var player: CharacterBody2D = game.get_node_or_null("Player") as CharacterBody2D
    if world == null or player == null:
        _fail("World TileMapLayer or Player CharacterBody2D is missing")
        return

    if world.tile_set == null:
        _fail("World has no TileSet")
        return
    if world.tile_set.tile_shape != TileSet.TILE_SHAPE_ISOMETRIC:
        _fail("World is not using isometric tiles")
        return
    if world.tile_set.tile_size != Vector2i(64, 32):
        _fail("Incorrect tile size")
        return
    if world.get_used_cells().size() != 400:
        _fail("Expected 400 floor cells")
        return
    if world.get_cell_source_id(Vector2i(10, 10)) != 0:
        _fail("Spawn tile is not populated")
        return
    if not world.call("has_ground_at", player.global_position):
        _fail("Player is not standing on the map")
        return
    if world.call("has_ground_at", Vector2(100000, 100000)):
        _fail("Out-of-bounds point is unexpectedly walkable")
        return

    for action: String in ["move_up", "move_down", "move_left", "move_right"]:
        if not InputMap.has_action(action):
            _fail("Missing input action: " + action)
            return

    print("SMOKE_OK | isometric=64x32 tiles=400 movement_actions=4")
    quit(0)


func _fail(reason: String) -> void:
    push_error("SMOKE_FAIL | " + reason)
    quit(1)
