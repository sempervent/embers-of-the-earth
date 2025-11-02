extends Node
class_name EntropySystem

## Tracks Order vs Wild paths and triggers awakening events

signal entropy_changed(order: float, wild: float)
signal milestone_reached(event_id: String, path: String)
signal ending_triggered(ending_type: String)

var order_level: float = 0.0  # 0-100
var wild_level: float = 0.0   # 0-100

var awakening_events: Array[Dictionary] = []
var triggered_events: Array[String] = []

var game_manager: GameManager
var atmosphere_manager: AtmosphereManager

const MAX_ENTROPY = 100.0

func _ready():
	_load_awakening_events()
	game_manager = GameManager.instance
	atmosphere_manager = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager

func _load_awakening_events():
	## Load awakening events from JSON
	var loader = DataLoader.new()
	awakening_events = loader.load_json_file("res://data/narrative/awakening_events.json")

func add_order_entropy(amount: float):
	## Add to order level
	order_level = min(MAX_ENTROPY, order_level + amount)
	_check_milestones()
	entropy_changed.emit(order_level, wild_level)

func add_wild_entropy(amount: float):
	## Add to wild level
	wild_level = min(MAX_ENTROPY, wild_level + amount)
	_check_milestones()
	entropy_changed.emit(order_level, wild_level)

func _check_milestones():
	## Check if any milestone events should trigger
	for event in awakening_events:
		var event_id = event.get("id", "")
		if triggered_events.has(event_id):
			continue
		
		var path = event.get("path", "")
		var threshold = event.get("threshold", 0)
		
		var level = order_level if path == "order" else wild_level
		
		if level >= threshold:
			_trigger_event(event)
			triggered_events.append(event_id)

func _trigger_event(event: Dictionary):
	## Trigger an awakening event
	var event_id = event.get("id", "")
	var path = event.get("path", "")
	var effects = event.get("effects", {})
	var name = event.get("name", "Unknown Event")
	var description = event.get("description", "")
	
	milestone_reached.emit(event_id, path)
	
	# Apply effects
	if effects.has("ending"):
		var ending_type = effects.get("ending")
		ending_triggered.emit(ending_type)
		_trigger_ending(ending_type)
	
	if effects.has("weather"):
		var weather_type = effects.get("weather")
		if atmosphere_manager and atmosphere_manager.weather_system:
			# Would set weather
			pass
	
	if effects.has("music_layer"):
		var layer = effects.get("music_layer")
		if atmosphere_manager and atmosphere_manager.procedural_music:
			# Would enable music layer
			pass
	
	if effects.has("transform_soil"):
		var soil_type = effects.get("transform_soil")
		_transform_soil(soil_type)
	
	if effects.has("transform_all_soil"):
		var soil_type = effects.get("transform_all_soil")
		_transform_all_soil(soil_type)
	
	if effects.has("spawn_steam_vents"):
		var count = effects.get("spawn_steam_vents")
		_spawn_steam_vents(count)
	
	if effects.has("spawn_fungal_growth"):
		var count = effects.get("spawn_fungal_growth")
		_spawn_fungal_growth(count)
	
	if effects.has("crop_damage"):
		var damage_percent = effects.get("crop_damage")
		_damage_crops(damage_percent)
	
	if effects.has("building_damage"):
		var damage_percent = effects.get("building_damage")
		_damage_buildings(damage_percent)
	
	# Add journal entry
	if atmosphere_manager and atmosphere_manager.journal_system:
		var player_name = "Unknown"
		if game_manager and game_manager.player:
			player_name = game_manager.player.name
		
		atmosphere_manager.journal_system.add_entry("machine_event", {
			"name": player_name,
			"event": name,
			"description": description,
			"year": GameManager.current_year,
			"generation": 1
		})

func _trigger_ending(ending_type: String):
	## Trigger ending sequence
	# Would show ending screen, credits, etc.
	print("ENDING TRIGGERED: " + ending_type)
	
	# Update music for ending
	if atmosphere_manager and atmosphere_manager.procedural_music:
		if ending_type == "order":
			atmosphere_manager.procedural_music.update_condition("machine_awakening", true)
		elif ending_type == "wild":
			atmosphere_manager.procedural_music.update_condition("machine_awakening", false)
	
	# Update weather
	if atmosphere_manager and atmosphere_manager.weather_system:
		if ending_type == "order":
			atmosphere_manager.weather_system._transition_to_weather(
				WeatherSystem.WeatherType.STEAM_FOG, 1.0, 999.0
			)
		elif ending_type == "wild":
			atmosphere_manager.weather_system._transition_to_weather(
				WeatherSystem.WeatherType.DRY_WIND, 1.0, 999.0
			)

func _transform_soil(soil_type: String):
	## Transform random tiles to new soil type
	if not game_manager or not game_manager.farm_grid:
		return
	
	var tiles = game_manager.farm_grid.tiles
	var tile_list = tiles.values()
	if tile_list.is_empty():
		return
	
	# Transform 3-5 random tiles
	var count = randi_range(3, 5)
	for i in range(min(count, tile_list.size())):
		var tile = tile_list[randi() % tile_list.size()]
		tile.soil_type = soil_type
		tile._load_soil_data()

func _transform_all_soil(soil_type: String):
	## Transform all tiles to new soil type
	if not game_manager or not game_manager.farm_grid:
		return
	
	for tile in game_manager.farm_grid.tiles.values():
		tile.soil_type = soil_type
		tile._load_soil_data()

func _spawn_steam_vents(count: int):
	## Spawn steam vents on farm
	if atmosphere_manager and atmosphere_manager.visual_effects:
		for i in range(count):
			var pos = Vector2(randf_range(100, 500), randf_range(100, 500))
			atmosphere_manager.visual_effects._create_steam_vent(pos)

func _spawn_fungal_growth(count: int):
	## Spawn fungal growth
	# Would create visual fungal growth sprites
	pass

func _damage_crops(damage_percent: float):
	## Damage crops on farm
	if not game_manager or not game_manager.farm_grid:
		return
	
	var tiles = game_manager.farm_grid.tiles.values()
	for tile in tiles:
		if tile.current_crop != "" and randf() < (damage_percent / 100.0):
			# Kill crop
			tile.current_crop = ""
			tile.crop_growth_stage = 0
			tile.is_tilled = false

func _damage_buildings(damage_percent: float):
	## Damage buildings
	if not game_manager:
		return
	
	var production = get_tree().get_first_node_in_group("production") as ProductionSystem
	if not production:
		return
	
	var buildings = production.buildings.keys()
	for building_id in buildings:
		if randf() < (damage_percent / 100.0):
			# Destroy building (remove from production system)
			production.buildings.erase(building_id)

# Hooks for gameplay actions
func on_building_placed(building_id: String):
	## Called when building is placed
	add_order_entropy(2.0)

func on_crop_planted(crop_name: String, biomechanical: bool):
	## Called when crop is planted
	if biomechanical:
		add_order_entropy(0.5)
	else:
		add_wild_entropy(0.5)

func on_faction_choice(faction_id: String):
	## Called when player makes faction choice
	match faction_id:
		"machinists", "rusted_brotherhood":
			add_order_entropy(5.0)
		"root_keepers":
			add_wild_entropy(5.0)
		"ash_caravans":
			# Neutral
			pass

func get_entropy_data() -> Dictionary:
	## Get entropy state for saving
	return {
		"order_level": order_level,
		"wild_level": wild_level,
		"triggered_events": triggered_events.duplicate()
	}

func load_entropy_data(data: Dictionary):
	## Load entropy state
	order_level = data.get("order_level", 0.0)
	wild_level = data.get("wild_level", 0.0)
	triggered_events = data.get("triggered_events", [])

