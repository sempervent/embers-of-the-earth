extends Node
class_name ProductionSystem

## Manages production buildings and resource processing

signal production_started(building_id: String, recipe_id: String)
signal production_completed(building_id: String, outputs: Dictionary)
signal production_failed(building_id: String, reason: String)

var buildings: Dictionary = {}  # building_id -> BuildingData
var production_queues: Dictionary = {}  # building_id -> [RecipeData]

var recipes: Array[Dictionary] = []
var building_definitions: Array[Dictionary] = []

var player: Player
var game_manager: GameManager

func _ready():
	_load_data()
	player = GameManager.instance.player if GameManager.instance else null
	game_manager = GameManager.instance

func _load_data():
	## Load recipes and building definitions
	var loader = DataLoader.new()
	recipes = loader.load_json_file("res://data/buildings/recipes.json")
	building_definitions = loader.load_json_file("res://data/buildings/buildings.json")

func place_building(building_id: String, position: Vector2) -> bool:
	## Place a building at position
	var definition = _get_building_definition(building_id)
	if definition.is_empty():
		return false
	
	# Check if player can afford it
	var cost = definition.get("cost", {})
	if not player:
		return false
	
	var inventory = player.get_inventory()
	for item in cost:
		var required = cost[item]
		var available = inventory.get(item, 0)
		if available < required:
			push_warning("Cannot afford building! Need " + str(required) + " " + item)
			return false
	
	# Pay cost
	for item in cost:
		player.remove_item(item, cost[item])
	
	# Create building
	var building_data = {
		"id": building_id,
		"position": {"x": position.x, "y": position.y},
		"definition": definition,
		"current_recipe": null,
		"time_remaining": 0,
		"queue": []
	}
	
	buildings[building_id] = building_data
	production_queues[building_id] = []
	
	production_started.emit(building_id, "placed")
	return true

func start_production(building_id: String, recipe_name: String) -> bool:
	## Start a recipe in a building
	var building = buildings.get(building_id)
	if not building:
		return false
	
	var recipe = _get_recipe(recipe_name, building_id)
	if recipe.is_empty():
		return false
	
	# Check if inputs are available
	var inputs = recipe.get("in", {})
	var inventory = player.get_inventory()
	
	for item in inputs:
		var required = inputs[item]
		var available = inventory.get(item, 0)
		if available < required:
			push_warning("Not enough " + item + "! Need " + str(required))
			return false
	
	# Consume inputs
	for item in inputs:
		player.remove_item(item, inputs[item])
	
	# Start production
	var production_time = recipe.get("time", 1)
	building["current_recipe"] = recipe
	building["time_remaining"] = production_time
	
	production_started.emit(building_id, recipe_name)
	return true

func queue_recipe(building_id: String, recipe_name: String) -> bool:
	## Queue a recipe for production
	var building = buildings.get(building_id)
	if not building:
		return false
	
	var recipe = _get_recipe(recipe_name, building_id)
	if recipe.is_empty():
		return false
	
	# Add to queue
	if not production_queues.has(building_id):
		production_queues[building_id] = []
	
	production_queues[building_id].append(recipe)
	return true

func process_day():
	## Process all production buildings for one day
	for building_id in buildings:
		var building = buildings[building_id]
		
		if building["current_recipe"] == null:
			# Try to start next queued recipe
			var queue = production_queues.get(building_id, [])
			if not queue.is_empty():
				var recipe = queue.pop_front()
				
				# Check if inputs available
				var inputs = recipe.get("in", {})
				var inventory = player.get_inventory()
				var can_start = true
				
				for item in inputs:
					var required = inputs[item]
					var available = inventory.get(item, 0)
					if available < required:
						can_start = false
						break
				
				if can_start:
					# Consume inputs
					for item in inputs:
						player.remove_item(item, inputs[item])
					
					# Start production
					var production_time = recipe.get("time", 1)
					building["current_recipe"] = recipe
					building["time_remaining"] = production_time
		else:
			# Process current recipe
			building["time_remaining"] = building.get("time_remaining", 0) - 1
			
			if building["time_remaining"] <= 0:
				# Production complete
				var recipe = building["current_recipe"]
				var outputs = recipe.get("out", {})
				
				# Add outputs to inventory
				for item in outputs:
					player.add_item(item, outputs[item])
				
				production_completed.emit(building_id, outputs)
				
				# Clear current recipe
				building["current_recipe"] = null
				building["time_remaining"] = 0

func _get_building_definition(building_id: String) -> Dictionary:
	## Get building definition by ID
	for definition in building_definitions:
		if definition.get("id") == building_id:
			return definition
	return {}

func _get_recipe(recipe_name: String, building_id: String) -> Dictionary:
	## Get recipe by name and building
	for recipe in recipes:
		var recipe_building = recipe.get("building", "")
		var name = recipe.get("name", "")
		if recipe_building == building_id and (name == recipe_name or name == ""):
			return recipe
	return {}

func get_building_queue(building_id: String) -> Array:
	## Get production queue for building
	return production_queues.get(building_id, []).duplicate()

func get_production_data() -> Dictionary:
	## Get production system state for saving
	var data = {
		"buildings": {},
		"queues": {}
	}
	
	for building_id in buildings:
		data["buildings"][building_id] = buildings[building_id].duplicate()
		data["queues"][building_id] = production_queues.get(building_id, []).duplicate()
	
	return data

func load_production_data(data: Dictionary):
	## Load production system state
	if data.has("buildings"):
		buildings = data.get("buildings", {})
	if data.has("queues"):
		production_queues = data.get("queues", {})

