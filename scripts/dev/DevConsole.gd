extends Control
class_name DevConsole

## Developer console with command registry

signal command_executed(command: String, args: Array)

var is_visible: bool = false
var command_history: Array[String] = []
var history_index: int = -1

var commands: Dictionary = {}

@onready var console_output: RichTextLabel = $VBoxContainer/Output
@onready var command_input: LineEdit = $VBoxContainer/InputContainer/CommandInput
@onready var submit_button: Button = $VBoxContainer/InputContainer/SubmitButton

func _ready():
	set_visible(false)
	add_to_group("dev_console")
	
	# Only show in dev builds
	if not OS.is_debug_build():
		queue_free()
		return
	
	_register_commands()
	
	if command_input:
		command_input.text_submitted.connect(_on_command_submitted)
	if submit_button:
		submit_button.pressed.connect(_on_submit_pressed)

func _input(event):
	if event.is_action_pressed("toggle_console"):
		toggle_console()
	
	if is_visible and event.is_action_pressed("ui_accept"):
		_on_submit_pressed()

func toggle_console():
	## Toggle console visibility
	is_visible = !is_visible
	set_visible(is_visible)
	
	if is_visible and command_input:
		command_input.grab_focus()

func _register_commands():
	## Register all console commands
	commands = {
		"help": _cmd_help,
		"spawn": _cmd_spawn,
		"item": _cmd_item,
		"weather": _cmd_weather,
		"day": _cmd_day,
		"entropy": _cmd_entropy,
		"teleport": _cmd_teleport,
		"clear": _cmd_clear,
		"seed": _cmd_seed,
		"marriage": _cmd_marriage,
		"faction": _cmd_faction,
		"build": _cmd_build,
		"harvest_all": _cmd_harvest_all
	}

func _on_command_submitted(text: String):
	## Handle command submission
	_execute_command(text)

func _on_submit_pressed():
	## Submit button pressed
	if command_input:
		_execute_command(command_input.text)
		command_input.text = ""

func _execute_command(input: String):
	## Execute a console command
	if input.is_empty():
		return
	
	command_history.append(input)
	history_index = command_history.size()
	
	_append_output("> " + input, Color(0.8, 0.8, 0.8))
	
	var parts = input.split(" ", false)
	var command = parts[0].to_lower()
	var args = parts.slice(1)
	
	if commands.has(command):
		var result = commands[command].call(args)
		if result != null:
			_append_output(str(result), Color(0.6, 0.8, 1.0))
	else:
		_append_output("Unknown command: " + command, Color(1.0, 0.5, 0.5))

func _append_output(text: String, color: Color = Color.WHITE):
	## Append text to console output
	if console_output:
		console_output.append_text("[color=#" + color.to_html() + "]" + text + "[/color]\n")

# Command implementations
func _cmd_help(args: Array) -> String:
	var help_text = "Available commands:\n"
	for cmd in commands.keys():
		help_text += "  " + cmd + "\n"
	return help_text

func _cmd_spawn(args: Array) -> String:
	if args.size() < 2:
		return "Usage: spawn <item_id> <quantity>"
	
	var item_id = args[0]
	var quantity = int(args[1])
	
	var player = GameManager.instance.player if GameManager.instance else null
	if player:
		player.add_item(item_id, quantity)
		return "Spawned " + str(quantity) + "x " + item_id
	return "Player not found"

func _cmd_item(args: Array) -> String:
	var player = GameManager.instance.player if GameManager.instance else null
	if not player:
		return "Player not found"
	
	var inventory = player.get_inventory()
	var output = "Inventory:\n"
	for item in inventory:
		output += "  " + item + ": " + str(inventory[item]) + "\n"
	return output

func _cmd_weather(args: Array) -> String:
	var atmosphere = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	if not atmosphere or not atmosphere.weather_system:
		return "Weather system not found"
	
	if args.size() < 1:
		return "Usage: weather <type> [intensity]"
	
	var weather_type_str = args[0].to_upper()
	var intensity = float(args[1]) if args.size() > 1 else 1.0
	
	var weather_type = WeatherSystem.WeatherType.CLEAR
	match weather_type_str:
		"ASH_FALL":
			weather_type = WeatherSystem.WeatherType.ASH_FALL
		"DUST_STORM":
			weather_type = WeatherSystem.WeatherType.DUST_STORM
		"STATIC_STORM":
			weather_type = WeatherSystem.WeatherType.STATIC_STORM
		"STEAM_FOG":
			weather_type = WeatherSystem.WeatherType.STEAM_FOG
		"DRY_WIND":
			weather_type = WeatherSystem.WeatherType.DRY_WIND
	
	atmosphere.weather_system._transition_to_weather(weather_type, intensity, 60.0)
	return "Weather set to: " + weather_type_str

func _cmd_day(args: Array) -> String:
	var count = int(args[0]) if args.size() > 0 else 1
	
	if GameManager.instance:
		for i in range(count):
			GameManager.instance.advance_day()
		return "Advanced " + str(count) + " day(s)"
	return "GameManager not found"

func _cmd_entropy(args: Array) -> String:
	var entropy = get_tree().get_first_node_in_group("entropy") as EntropySystem
	if not entropy:
		return "Entropy system not found"
	
	if args.size() < 2:
		return "Usage: entropy <order|wild> <amount>"
	
	var path = args[0].to_lower()
	var amount = float(args[1])
	
	if path == "order":
		entropy.add_order_entropy(amount)
		return "Order: " + str(entropy.order_level)
	elif path == "wild":
		entropy.add_wild_entropy(amount)
		return "Wild: " + str(entropy.wild_level)
	else:
		return "Invalid path (order/wild)"

func _cmd_teleport(args: Array) -> String:
	if args.size() < 1:
		return "Usage: teleport <region_id>"
	
	var world = get_tree().get_first_node_in_group("world") as WorldController
	if not world:
		return "World controller not found"
	
	var region_id = args[0]
	if world.fast_travel(region_id):
		return "Teleported to " + region_id
	return "Region not found: " + region_id

func _cmd_clear(args: Array) -> String:
	if console_output:
		console_output.text = ""
	return "Console cleared"

func _cmd_seed(args: Array) -> String:
	if args.size() > 0:
		seed(int(args[0]))
		randomize()
		return "RNG seed set to: " + args[0]
	else:
		var current_seed = randi()
		seed(current_seed)
		return "Current seed: " + str(current_seed)

func _cmd_marriage(args: Array) -> String:
	var lineage = get_tree().get_first_node_in_group("lineage") as LineageSystem
	if not lineage:
		return "Lineage system not found"
	
	if args.size() < 1:
		return "Usage: marriage <faction_id>"
	
	var faction_id = args[0]
	var contract = lineage.propose_marriage(faction_id)
	if contract.is_empty():
		return "Marriage proposal failed"
	
	lineage.accept_marriage(contract)
	return "Marriage accepted with " + faction_id

func _cmd_faction(args: Array) -> String:
	var player = GameManager.instance.player if GameManager.instance else null
	if not player:
		return "Player not found"
	
	var output = "Faction Relations:\n"
	for faction in player.faction_relations:
		output += "  " + faction + ": " + str(player.faction_relations[faction]) + "\n"
	return output

func _cmd_build(args: Array) -> String:
	if args.size() < 3:
		return "Usage: build <building_id> <x> <y>"
	
	var production = get_tree().get_first_node_in_group("production") as ProductionSystem
	if not production:
		return "Production system not found"
	
	var building_id = args[0]
	var x = float(args[1])
	var y = float(args[2])
	
	if production.place_building(building_id, Vector2(x, y)):
		return "Building placed: " + building_id
	return "Failed to place building"

func _cmd_harvest_all(args: Array) -> String:
	var farm_grid = GameManager.instance.farm_grid if GameManager.instance else null
	if not farm_grid:
		return "Farm grid not found"
	
	var harvested = 0
	for tile in farm_grid.tiles.values():
		if tile.is_ready_to_harvest():
			var results = tile.harvest()
			if not results.is_empty():
				harvested += 1
				if GameManager.instance and GameManager.instance.player:
					for item in results:
						GameManager.instance.player.add_item(item, results[item])
	
	return "Harvested " + str(harvested) + " crops"

