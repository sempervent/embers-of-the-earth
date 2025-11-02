extends CharacterBody2D
# Note: class_name causes issues with type resolution - using preloads instead
# class_name PlayerController

const FarmGridClass = preload("res://scripts/FarmGrid.gd")
const TileClass = preload("res://scripts/Tile.gd")

## Handles player movement and interaction with tiles

signal tile_interacted(tile: Node2D, action: String)  # Node2D will be Tile

const SPEED = 60.0
const TILE_SIZE = 32

var farm_grid: Node2D  # Will be FarmGrid
var current_selected_tile: Node2D = null  # Will be Tile
var selected_action: String = "none"  # "till", "plant", "harvest"

enum Action {
	NONE,
	TILL,
	PLANT,
	HARVEST
}

var current_action: Action = Action.NONE
var selected_crop: String = "Ironwheat"

func _ready():
	# Find farm grid in scene
	var grid_node = get_node_or_null("../../FarmGrid")
	if grid_node:
		farm_grid = grid_node  # Will be FarmGrid type
	if not farm_grid:
		farm_grid = get_tree().get_first_node_in_group("farm_grid")

func _physics_process(delta):
	_handle_movement(delta)
	_handle_interaction()

func _handle_movement(delta):
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	
	direction = direction.normalized()
	velocity = direction * SPEED
	
	move_and_slide()
	
	# Snap to grid (optional - for pixel perfect movement)
	position = Vector2(
		round(position.x / TILE_SIZE) * TILE_SIZE,
		round(position.y / TILE_SIZE) * TILE_SIZE
	)

func _handle_interaction():
	if Input.is_action_just_pressed("interact"):
		var tile_pos = Vector2i(
			int(position.x / TILE_SIZE),
			int(position.y / TILE_SIZE)
		)
		
		if farm_grid:
			var tile = farm_grid.get_tile(tile_pos)
			if tile:
				_perform_action(tile)

func _perform_action(tile: Node2D):  # tile will be Tile type
	# Auto-detect action if NONE is selected
	if current_action == Action.NONE:
		if tile.is_ready_to_harvest():
			current_action = Action.HARVEST
		elif not tile.is_tilled:
			current_action = Action.TILL
		elif tile.is_tilled and tile.current_crop == "":
			current_action = Action.PLANT
	
	match current_action:
		Action.TILL:
			if tile.till_soil():
				print("Tilled tile at ", tile.tile_position)
				tile_interacted.emit(tile, "tilled")
			current_action = Action.NONE  # Reset after action
		
		Action.PLANT:
			if tile.plant_crop(selected_crop):
				print("Planted ", selected_crop, " at ", tile.tile_position)
				tile_interacted.emit(tile, "planted")
				# Remove seed from inventory if needed
				if GameManager.instance and GameManager.instance.player:
					GameManager.instance.player.remove_item(selected_crop.to_lower() + "_seed", 1)
			current_action = Action.NONE  # Reset after action
		
		Action.HARVEST:
			if tile.is_ready_to_harvest():
				var results = tile.harvest()
				if not results.is_empty():
					print("Harvested from tile at ", tile.tile_position, ": ", results)
					tile_interacted.emit(tile, "harvested")
					# Add items to inventory
					if GameManager.instance and GameManager.instance.player:
						for item in results:
							GameManager.instance.player.add_item(item, results[item])
			current_action = Action.NONE  # Reset after action
		
		_:
			# Default: select tile for inspection
			current_selected_tile = tile
			print("Selected tile at ", tile.tile_position, " - Soil: ", tile.soil_type, ", Crop: ", tile.current_crop)

func set_action(action: Action):
	current_action = action

func set_selected_crop(crop_name: String):
	selected_crop = crop_name

func get_tile_under_player() -> Node2D:  # Returns Tile
	if farm_grid:
		var tile_pos = Vector2i(
			int(position.x / TILE_SIZE),
			int(position.y / TILE_SIZE)
		)
		return farm_grid.get_tile(tile_pos)
	return null

