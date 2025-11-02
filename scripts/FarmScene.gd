extends Node2D
# Note: class_name causes issues - using preloads instead
# class_name FarmScene

const FarmGridClass = preload("res://scripts/FarmGrid.gd")
const PlayerControllerClass = preload("res://scripts/PlayerController.gd")
const GameUIClass = preload("res://scripts/GameUI.gd")
const AtmosphereManagerClass = preload("res://scripts/atmosphere/AtmosphereManager.gd")

## Main farm scene controller

@onready var farm_grid: Node2D = $FarmGrid  # Will be FarmGrid
@onready var player: CharacterBody2D = $PlayerController  # Will be PlayerController
@onready var game_ui: Control = $CanvasLayer/GameUI  # Will be GameUI

var atmosphere_manager: Node  # Will be AtmosphereManager

func _ready():
	# GameManager is set as autoload, so it should already exist
	var game_manager = GameManager.instance
	if not game_manager:
		push_error("GameManager not found as autoload!")
		return
	
	# Connect farm grid to game manager
	game_manager.farm_grid = farm_grid
	
	# Initialize atmosphere systems
	var atm_class = load("res://scripts/atmosphere/AtmosphereManager.gd")
	if atm_class:
		var atm_instance = atm_class.new()
		atmosphere_manager = atm_instance
		atmosphere_manager.name = "AtmosphereManager"
		add_child(atmosphere_manager)
	
	# Connect player signals
	if player:
		player.tile_interacted.connect(_on_tile_interacted)
	
	# Setup input actions
	_setup_input_map()

func _setup_input_map():
	## Sets up input map actions if they don't exist
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
		var event = InputEventKey.new()
		event.keycode = KEY_E
		InputMap.action_add_event("interact", event)

func _on_tile_interacted(tile: Node2D, action: String):  # tile will be Tile type
	## Called when player interacts with a tile
	print("Tile interaction: ", action, " on tile ", tile.tile_position)
	# Update UI if needed

