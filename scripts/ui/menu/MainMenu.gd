extends Control
class_name MainMenu

## Main menu with title screen, save slots, settings

signal new_game_requested()
signal load_game_requested(slot: int)
signal settings_requested()
signal quit_requested()

var save_slots: Array[Dictionary] = []

@onready var title_label: Label = $VBoxContainer/TitleSection/TitleLabel
@onready var new_game_button: Button = $VBoxContainer/MainButtons/NewGameButton
@onready var load_game_button: Button = $VBoxContainer/MainButtons/LoadGameButton
@onready var settings_button: Button = $VBoxContainer/MainButtons/SettingsButton
@onready var quit_button: Button = $VBoxContainer/MainButtons/QuitButton
@onready var save_slot_list: ItemList = $VBoxContainer/SaveSlots/SaveSlotList
@onready var version_label: Label = $VBoxContainer/VersionLabel

func _ready():
	set_visible(true)
	add_to_group("main_menu")
	
	_connect_signals()
	_load_save_slots()
	_update_ui()

func _connect_signals():
	## Connect button signals
	if new_game_button:
		new_game_button.pressed.connect(_on_new_game_pressed)
	if load_game_button:
		load_game_button.pressed.connect(_on_load_game_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	
	if save_slot_list:
		save_slot_list.item_selected.connect(_on_save_slot_selected)

func _load_save_slots():
	## Load save slot information
	save_slots.clear()
	
	# Load regular saves
	for i in range(5):
		var path = "user://save_" + str(i) + ".json"
		var save_info = _get_save_info(path)
		if save_info.has("exists") and save_info["exists"]:
			save_slots.append(save_info)
	
	# Load autosaves
	var autosave_manager = get_tree().get_first_node_in_group("autosave") as AutosaveManager
	if autosave_manager:
		for i in range(3):
			var autosave_info = autosave_manager.get_autosave_info(i)
			if not autosave_info.is_empty():
				autosave_info["slot_type"] = "autosave"
				autosave_info["slot_index"] = i
				save_slots.append(autosave_info)

func _get_save_info(path: String) -> Dictionary:
	## Get save file information
	if not FileAccess.file_exists(path):
		return {"exists": false}
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"exists": false}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_string) != OK:
		return {"exists": false}
	
	var data = json.get_data()
	var game_state = data.get("game_state", {})
	
	return {
		"exists": true,
		"path": path,
		"year": game_state.get("current_year", 1),
		"day": game_state.get("current_day", 1),
		"player_name": data.get("player_state", {}).get("name", "Unknown"),
		"timestamp": data.get("timestamp", 0)
	}

func _update_ui():
	## Update UI with save slots
	if save_slot_list:
		save_slot_list.clear()
		
		for save_info in save_slots:
			var display_text = ""
			
			if save_info.has("slot_type") and save_info["slot_type"] == "autosave":
				display_text = "[AUTOSAVE] "
			else:
				display_text = "Save Slot "
			
			var player_name = save_info.get("player_name", "Unknown")
			var year = save_info.get("year", 1)
			var day = save_info.get("day", 1)
			
			display_text += player_name + " - Year " + str(year) + ", Day " + str(day)
			save_slot_list.add_item(display_text)
	
	if version_label:
		version_label.text = "Version 0.1.0 - Alpha Build"

func _on_new_game_pressed():
	## Start new game
	new_game_requested.emit()
	# Transition to character creation scene
	get_tree().change_scene_to_file("res://scenes/ui/character_creation.tscn")

func _on_load_game_pressed():
	## Load game
	var selected = save_slot_list.get_selected_items()
	if selected.is_empty():
		return
	
	var index = selected[0]
	if index >= save_slots.size():
		return
	
	var save_info = save_slots[index]
	
	# Load save
	if save_info.has("slot_type") and save_info["slot_type"] == "autosave":
		var autosave_manager = get_tree().get_first_node_in_group("autosave") as AutosaveManager
		if autosave_manager:
			autosave_manager.load_autosave(save_info.get("slot_index", 0))
	else:
		var path = save_info.get("path", "")
		if not path.is_empty():
			var file = FileAccess.open(path, FileAccess.READ)
			if file:
				var json_string = file.get_as_text()
				file.close()
				var json = JSON.new()
				if json.parse(json_string) == OK:
					SaveSchema.deserialize_game_state(json.get_data())
	
	load_game_requested.emit(index)

func _on_save_slot_selected(index: int):
	## Save slot selected (enable load button)
	pass

func _on_settings_pressed():
	## Open settings
	settings_requested.emit()

func _on_quit_pressed():
	## Quit game
	quit_requested.emit()
	get_tree().quit()

