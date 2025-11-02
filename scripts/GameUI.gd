extends Control
class_name GameUI

## Main game UI controller

@onready var date_label: Label = $VBoxContainer/DateLabel
@onready var player_age_label: Label = $VBoxContainer/PlayerInfo/PlayerAgeLabel
@onready var inventory_panel: Control = $VBoxContainer/InventoryPanel
@onready var inventory_list: ItemList = $VBoxContainer/InventoryPanel/ItemList
@onready var advance_day_button: Button = $VBoxContainer/Actions/AdvanceDayButton
@onready var action_buttons: HBoxContainer = $VBoxContainer/Actions/ActionButtons

var game_manager: GameManager

func _ready():
	game_manager = GameManager.instance
	
	if game_manager:
		game_manager.day_advanced.connect(_on_day_advanced)
		game_manager.year_advanced.connect(_on_year_advanced)
		
		if game_manager.player:
			game_manager.player.player_aged.connect(_on_player_aged)
	
	advance_day_button.pressed.connect(_on_advance_day_pressed)
	_update_ui()

func _update_ui():
	## Updates all UI elements
	if game_manager:
		date_label.text = game_manager.get_date_string()
		
		if game_manager.player:
			var player_name = game_manager.player.character_name if game_manager.player.has("character_name") else game_manager.player.name
			player_age_label.text = player_name + " - Age " + str(game_manager.player.age)
			_update_inventory()
	
	_update_action_buttons()

func _update_inventory():
	## Updates the inventory display
	inventory_list.clear()
	
	if game_manager and game_manager.player:
		var inventory = game_manager.player.get_inventory()
		for item in inventory:
			var quantity = inventory[item]
			inventory_list.add_item(item + ": " + str(quantity))

func _update_action_buttons():
	## Updates action button states
	# Can disable/enable buttons based on game state
	pass

func _on_day_advanced(day: int):
	_update_ui()

func _on_year_advanced(year: int):
	_update_ui()

func _on_player_aged(new_age: int):
	_update_ui()

func _on_advance_day_pressed():
	if game_manager:
		game_manager.advance_day()
		_update_ui()

