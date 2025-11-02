extends Node2D
class_name FarmGrid

## Manages the grid of farm tiles

const TileClass = preload("res://scripts/Tile.gd")

signal tile_selected(tile: Node2D)  # Node2D will be Tile

const GRID_WIDTH = 10
const GRID_HEIGHT = 10
const TILE_SIZE = 32

var tiles: Dictionary = {}  # Key: Vector2i, Value: Tile

@onready var tile_scene = preload("res://scenes/Tile.tscn") if ResourceLoader.exists("res://scenes/Tile.tscn") else null

func _ready():
	_initialize_grid()

func _initialize_grid():
	## Creates the initial farm grid with random soil types
	var soil_types = ["ferro_soil", "fungal_soil", "ash_soil", "ash_soil", "ash_soil"]  # Weighted distribution
	
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var pos = Vector2i(x, y)
			var soil_type = soil_types[randi() % soil_types.size()]
			
			# Create tile instance
			var tile: Node2D  # Will be Tile type
			if tile_scene:
				tile = tile_scene.instantiate() as Node2D
			else:
				var tile_class = TileClass
				tile = tile_class.new()
			
			tile.tile_position = pos
			tile.soil_type = soil_type
			tile.position = Vector2(pos.x * TILE_SIZE, pos.y * TILE_SIZE)
			add_child(tile)
			tiles[pos] = tile
			
			# Connect tile signals
			tile.tile_changed.connect(_on_tile_changed)

func get_tile(pos: Vector2i) -> Node2D:  # Returns Tile
	## Returns the tile at the given position
	return tiles.get(pos, null)

func get_tile_at_world_pos(world_pos: Vector2) -> Node2D:  # Returns Tile
	## Returns the tile at the given world position
	var grid_pos = Vector2i(
		int(world_pos.x / TILE_SIZE),
		int(world_pos.y / TILE_SIZE)
	)
	return get_tile(grid_pos)

func _on_tile_changed(tile: Node2D):  # tile will be Tile type
	## Called when a tile is modified
	pass  # Can be used for visual updates

func advance_all_crops():
	## Advances all crops on the farm by one day
	for tile in tiles.values():
		if tile.current_crop != "":
			if tile.advance_growth():
				# Crop is ready to harvest (visual feedback could go here)
				pass

func till_tile(pos: Vector2i) -> bool:
	## Tills the tile at the given position
	var tile = get_tile(pos)
	if tile:
		return tile.till_soil()
	return false

func plant_crop(pos: Vector2i, crop_name: String) -> bool:
	## Plants a crop at the given position
	var tile = get_tile(pos)
	if tile:
		return tile.plant_crop(crop_name)
	return false

func harvest_tile(pos: Vector2i) -> Dictionary:
	## Harvests the crop at the given position
	var tile = get_tile(pos)
	if tile:
		return tile.harvest()
	return {}

func get_farm_data() -> Dictionary:
	## Returns farm data for saving
	var farm_data = {
		"tiles": []
	}
	
	for pos in tiles:
		var tile = tiles[pos]
		farm_data["tiles"].append(tile.get_tile_data())
	
	return farm_data

func load_farm_data(data: Dictionary):
	## Loads farm data from a dictionary
	# Clear existing tiles
	for tile in tiles.values():
		tile.queue_free()
	tiles.clear()
	
	# Load tiles
	if data.has("tiles"):
		for tile_data in data.get("tiles", []):
			var pos = Vector2i(tile_data.get("x", 0), tile_data.get("y", 0))
			var tile_class = TileClass
			var tile = tile_class.new(pos, tile_data.get("soil_type", "ash_soil"))
			tile.position = Vector2(pos.x * TILE_SIZE, pos.y * TILE_SIZE)
			tile.load_tile_data(tile_data)
			tile.tile_changed.connect(_on_tile_changed)
			add_child(tile)
			tiles[pos] = tile

