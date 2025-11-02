extends Node
class_name SliceLoader

## Loads and manages vertical slice mode

signal slice_started(slice_name: String)
signal slice_completed()
signal slice_condition_met(condition: String)

var active_slice: Dictionary = {}
var is_slice_mode: bool = false
var slice_conditions: Dictionary = {}

var game_manager: GameManager

func _ready():
	game_manager = GameManager.instance
	
	# Check for --slice command line argument
	var args = OS.get_cmdline_args()
	for i in range(args.size()):
		if args[i] == "--slice" and i + 1 < args.size():
			load_slice(args[i + 1])
			break

func load_slice(slice_id: String):
	## Load a vertical slice
	var loader = DataLoader.new()
	var slices = loader.load_json_file("res://data/slices/" + slice_id + ".json")
	
	if slices.is_empty() or typeof(slices) != TYPE_DICTIONARY:
		# Try loading directly as dictionary
		var file = FileAccess.open("res://data/slices/" + slice_id + ".json", FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var json = JSON.new()
			if json.parse(json_string) == OK:
				active_slice = json.get_data()
		else:
			push_error("Slice not found: " + slice_id)
			return
	else:
		active_slice = slices
	
	is_slice_mode = true
	_apply_slice_modifiers()
	slice_started.emit(slice_id)

func _apply_slice_modifiers():
	## Apply slice modifiers to game
	if not active_slice.has("modifiers"):
		return
	
	var modifiers = active_slice.get("modifiers", {})
	
	# Starting items
	if modifiers.has("starting_items"):
		var items = modifiers.get("starting_items", {})
		if game_manager and game_manager.player:
			for item in items:
				game_manager.player.add_item(item, items[item])
	
	# Crop growth multiplier
	if modifiers.has("crop_growth_multiplier"):
		var multiplier = modifiers.get("crop_growth_multiplier", 1.0)
		# Would apply to Tile.advance_growth()
		pass
	
	# Encounter rate
	if modifiers.has("encounter_rate"):
		var rate = modifiers.get("encounter_rate", 1.0)
		var world = get_tree().get_first_node_in_group("world") as WorldController
		if world and world.encounter_table:
			# Would adjust encounter weights
			pass
	
	# Entropy acceleration
	if modifiers.has("entropy_acceleration"):
		var acceleration = modifiers.get("entropy_acceleration", 1.0)
		var entropy = get_tree().get_first_node_in_group("entropy") as EntropySystem
		if entropy:
			# Would multiply entropy gains
			pass

func check_win_conditions():
	## Check if slice win conditions are met
	if not active_slice.has("win_conditions"):
		return
	
	var conditions = active_slice.get("win_conditions", {})
	
	# Check each condition
	var all_met = true
	
	if conditions.has("harvest_crops"):
		var target = conditions.get("harvest_crops", 0)
		var harvested = slice_conditions.get("harvested_crops", 0)
		if harvested < target:
			all_met = false
		else:
			slice_condition_met.emit("harvest_crops")
	
	if conditions.has("trade_completed"):
		var target = conditions.get("trade_completed", 0)
		var trades = slice_conditions.get("trades", 0)
		if trades < target:
			all_met = false
		else:
			slice_condition_met.emit("trade_completed")
	
	if conditions.has("building_placed"):
		var target = conditions.get("building_placed", 0)
		var buildings = slice_conditions.get("buildings_placed", 0)
		if buildings < target:
			all_met = false
		else:
			slice_condition_met.emit("building_placed")
	
	if conditions.has("entropy_event_triggered"):
		var triggered = slice_conditions.get("entropy_event", false)
		if not triggered:
			all_met = false
		else:
			slice_condition_met.emit("entropy_event")
	
	if all_met:
		_complete_slice()

func _complete_slice():
	## Complete the vertical slice
	is_slice_mode = false
	
	var end_sequence = active_slice.get("end_sequence", {})
	var show_credits = end_sequence.get("show_credits", true)
	var message = end_sequence.get("message", "Slice completed!")
	
	slice_completed.emit()
	
	# Show end message/credits
	if show_credits:
		_show_slice_completion(message)

func _show_slice_completion(message: String):
	## Show slice completion screen
	# Would show credits or completion message
	print("VERTICAL SLICE COMPLETE: " + message)

func track_condition(condition_id: String, value: int = 1):
	## Track progress toward win conditions
	if not slice_conditions.has(condition_id):
		slice_conditions[condition_id] = 0
	
	slice_conditions[condition_id] = slice_conditions[condition_id] + value
	check_win_conditions()

func is_in_slice_mode() -> bool:
	return is_slice_mode

func get_slice_data() -> Dictionary:
	return active_slice.duplicate()

