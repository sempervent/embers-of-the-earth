extends Node2D
class_name WorldController

## Controls overworld travel and encounters

signal travel_started(from_id: String, to_id: String)
signal travel_step_completed(days: int, distance: float)
signal travel_completed(destination_id: String)
signal travel_event(event_id: String, payload: Dictionary)
signal encounter_triggered(encounter: Dictionary)

var regions: Array[Dictionary] = []
var current_region_id: String = "home_farm"
var is_traveling: bool = false
var travel_path: Array[String] = []
var travel_days_remaining: int = 0
var travel_distance: float = 0.0

var encounter_table: EncounterTable
var game_manager: GameManager

# Travel costs per distance unit
const DAYS_PER_UNIT = 0.5  # Days per unit of distance
const FOOD_PER_DAY = 1     # Food units consumed per day
const FUEL_PER_UNIT = 0.5  # Fuel per unit of distance

func _ready():
	_load_regions()
	encounter_table = EncounterTable.new()
	game_manager = GameManager.instance
	
	if not game_manager:
		push_error("GameManager not found!")

func _load_regions():
	## Load regions from JSON file
	var loader = DataLoader.new()
	regions = loader.load_json_file("res://data/world/regions.json")

func get_region(region_id: String) -> Dictionary:
	## Get region data by ID
	for region in regions:
		if region.get("id") == region_id:
			return region
	return {}

func get_current_region() -> Dictionary:
	## Get current region data
	return get_region(current_region_id)

func calculate_travel_distance(from_id: String, to_id: String) -> float:
	## Calculate distance between two regions
	var from_region = get_region(from_id)
	var to_region = get_region(to_id)
	
	if from_region.is_empty() or to_region.is_empty():
		return 0.0
	
	var from_pos = from_region.get("position", {})
	var to_pos = to_region.get("position", {})
	
	var from_x = from_pos.get("x", 0)
	var from_y = from_pos.get("y", 0)
	var to_x = to_pos.get("x", 0)
	var to_y = to_pos.get("y", 0)
	
	return sqrt(pow(to_x - from_x, 2) + pow(to_y - from_y, 2))

func can_travel_to(region_id: String) -> bool:
	## Check if player can travel to a region
	if is_traveling:
		return false
	
	var current_region = get_current_region()
	if current_region.is_empty():
		return false
	
	var connections = current_region.get("connections", [])
	return connections.has(region_id)

func start_travel(destination_id: String) -> bool:
	## Start travel to destination
	if is_traveling:
		push_warning("Already traveling!")
		return false
	
	if not can_travel_to(destination_id):
		push_warning("Cannot travel to " + destination_id)
		return false
	
	var current_region = get_current_region()
	var destination = get_region(destination_id)
	
	if destination.is_empty():
		return false
	
	# Calculate travel cost
	travel_distance = calculate_travel_distance(current_region_id, destination_id)
	var days_needed = int(ceil(travel_distance * DAYS_PER_UNIT))
	var food_needed = days_needed * FOOD_PER_DAY
	var fuel_needed = int(ceil(travel_distance * FUEL_PER_UNIT))
	
	# Check if player has resources
	if game_manager and game_manager.player:
		var inventory = game_manager.player.get_inventory()
		if inventory.get("food", 0) < food_needed:
			push_warning("Not enough food! Need " + str(food_needed))
			return false
		if inventory.get("fuel", 0) < fuel_needed:
			push_warning("Not enough fuel! Need " + str(fuel_needed))
			return false
		
		# Consume resources
		game_manager.player.remove_item("food", food_needed)
		game_manager.player.remove_item("fuel", fuel_needed)
	
	# Start travel
	is_traveling = true
	travel_days_remaining = days_needed
	current_region_id = destination_id
	
	travel_started.emit(current_region_id, destination_id)
	
	# Process travel
	_process_travel()
	
	return true

func _process_travel():
	## Process travel day by day
	while travel_days_remaining > 0:
		# Advance one day
		travel_days_remaining -= 1
		
		if game_manager:
			game_manager.advance_day()
		
		# Roll for encounter
		var encounter = encounter_table.roll_encounter()
		if encounter and not encounter.is_empty():
			_handle_encounter(encounter)
		
		# Emit step signal
		travel_step_completed.emit(1, travel_distance / travel_days_remaining if travel_days_remaining > 0 else travel_distance)
		
		# Small delay for animation (optional)
		await get_tree().create_timer(0.1).timeout
	
	# Travel complete
	is_traveling = false
	travel_completed.emit(current_region_id)
	
	# Emit travel event
	travel_event.emit("travel_completed", {
		"destination": current_region_id,
		"days": travel_days_remaining,
		"distance": travel_distance
	})

func _handle_encounter(encounter: Dictionary):
	## Handle a travel encounter
	var encounter_id = encounter.get("id", "")
	var effects = encounter.get("effects", {})
	
	encounter_triggered.emit(encounter)
	travel_event.emit("encounter", {
		"id": encounter_id,
		"encounter": encounter
	})
	
	# Apply effects
	if game_manager and game_manager.player:
		var player = game_manager.player
		
		# Lose items
		if effects.has("lose_items"):
			var items = effects.get("lose_items", [])
			for item in items:
				var quantity = randf_range(1, 3)
				player.remove_item(item, int(quantity))
		
		# Gain items
		if effects.has("gain_items"):
			var items = effects.get("gain_items", {})
			for item in items:
				player.add_item(item, items[item])
		
		# Injury
		if effects.has("injury"):
			var injury = effects.get("injury")
			player.add_injury(injury)
		
		# Heal injury
		if effects.get("heal_injury", false):
			if not player.injuries.is_empty():
				player.injuries.pop_back()
		
		# Reputation changes
		if effects.has("reputation_gain"):
			# Would update faction reputation
			pass
		if effects.has("reputation_loss"):
			# Would update faction reputation
			pass
		
		# Trade opportunity
		if effects.get("trade_opportunity", false):
			# Would trigger trading UI
			pass
		
		# Damage (future: health system)
		if effects.has("damage"):
			var damage = effects.get("damage")
			# Would reduce player health/stamina
			pass
		
		# Lose days (forced delay)
		if effects.has("lose_days"):
			travel_days_remaining += effects.get("lose_days")
	
	# Send to atmosphere systems
	var atmosphere = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	if atmosphere:
		if atmosphere.journal_system:
			var encounter_name = encounter.get("name", "Unknown Encounter")
			var description = encounter.get("description", "")
			atmosphere.journal_system.add_entry("travel_event", {
				"name": game_manager.player.name if game_manager and game_manager.player else "Unknown",
				"event": encounter_name,
				"description": description,
				"year": GameManager.current_year,
				"generation": 1
			})

func fast_travel(destination_id: String) -> bool:
	## Debug function: fast travel without consuming days
	var old_region = current_region_id
	current_region_id = destination_id
	travel_started.emit(old_region, destination_id)
	travel_completed.emit(destination_id)
	return true

func get_available_destinations() -> Array[Dictionary]:
	## Get list of regions player can travel to
	if is_traveling:
		return []
	
	var current_region = get_current_region()
	if current_region.is_empty():
		return []
	
	var connections = current_region.get("connections", [])
	var destinations: Array[Dictionary] = []
	
	for conn_id in connections:
		var region = get_region(conn_id)
		if not region.is_empty():
			destinations.append(region)
	
	return destinations

