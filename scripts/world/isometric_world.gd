extends TileMapLayer
## An actual Godot TileMapLayer/TileSetAtlasSource, built from a placeholder atlas.
## Tile coordinate geometry: 64x32 isometric diamonds, 20x20 cells.
## In STEP 1, replace the placeholder atlas with a curated editable TileSet resource.

const TILE_SIZE: Vector2i = Vector2i(64, 32)
const GROUND_ATLAS: Texture2D = preload("res://assets/tiles/isometric_ground.png")

@export_range(2, 128, 1) var columns: int = 20
@export_range(2, 128, 1) var rows: int = 20


func _ready() -> void:
    _create_tileset()
    _fill_map()


func _create_tileset() -> void:
    var tiles: TileSet = TileSet.new()
    tiles.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
    tiles.tile_size = TILE_SIZE

    var atlas: TileSetAtlasSource = TileSetAtlasSource.new()
    atlas.texture = GROUND_ATLAS
    atlas.texture_region_size = TILE_SIZE
    atlas.create_tile(Vector2i(0, 0))
    atlas.create_tile(Vector2i(1, 0))
    tiles.add_source(atlas, 0)
    tile_set = tiles


func _fill_map() -> void:
    clear()
    for y: int in range(rows):
        for x: int in range(columns):
            var palette_id: int = (x + y) % 2
            set_cell(Vector2i(x, y), 0, Vector2i(palette_id, 0))


func has_ground_at(global_point: Vector2) -> bool:
    var cell: Vector2i = local_to_map(to_local(global_point))
    return get_cell_source_id(cell) == 0
