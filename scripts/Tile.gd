extends Node2D
class_name Tile

## Represents a single tile of farmland with soil memory and properties

signal tile_changed(tile: Tile)

@export var tile_position: Vector2i = Vector2i(0, 0)
@export var soil_type: String = "ash_soil"
@export var is_tilled: bool = false
@export var current_crop: String = ""
@export var crop_growth_stage: int = 0
@export var crop_days_in_stage: int = 0

var soil_data: Dictionary = {}
var memory: Dictionary = {
	"last_crop": "",
	"years_used": 0,
	"mood": "neutral"
}

var machine_affinity: float = 0.5
var nature_affinity: float = 0.5

func _init(pos: Vector2i = Vector2i.ZERO, soil: String = "ash_soil"):
	tile_position = pos
	soil_type = soil

func _ready():
	_load_soil_data()
	_update_affinities_from_soil()

const DataLoader = preload("res://scripts/DataLoader.gd")

func _load_soil_data():
	var all_soils = DataLoader.load_json_file("res://data/soil_types.json")
	
	for soil in all_soils:
		if soil.get("name") == soil_type:
			soil_data = soil.duplicate()
			break
	
	if soil_data.is_empty():
		push_error("Failed to load soil type: " + soil_type)

func _update_affinities_from_soil():
	if not soil_data.is_empty():
		machine_affinity = soil_data.get("machine_affinity_base", 0.5)
		nature_affinity = soil_data.get("nature_affinity_base", 0.5)

func till_soil() -> bool:
	## Tills the soil, making it ready for planting
	if is_tilled:
		return false
	
	is_tilled = true
	_update_memory("tilled")
	tile_changed.emit(self)
	return true

func plant_crop(crop_name: String) -> bool:
	## Plants a crop on this tile
	if not is_tilled or current_crop != "":
		return false
	
	var crops = DataLoader.load_json_file("res://data/crops.json")
	var crop_data: Dictionary = {}
	
	for crop in crops:
		if crop.get("name") == crop_name:
			crop_data = crop
			break
	
	if crop_data.is_empty():
		push_error("Failed to find crop: " + crop_name)
		return false
	
	# Check if soil is compatible
	var likes = crop_data.get("likes", [])
	var hates = crop_data.get("hates", [])
	
	if hates.has(soil_type):
		_update_memory("planted_" + crop_name + "_unhappy")
		memory["mood"] = "resentful"
	elif likes.has(soil_type):
		_update_memory("planted_" + crop_name + "_happy")
		memory["mood"] = "content"
	else:
		_update_memory("planted_" + crop_name)
		memory["mood"] = "neutral"
	
	current_crop = crop_name
	crop_growth_stage = 0
	crop_days_in_stage = 0
	tile_changed.emit(self)
	return true

func advance_growth() -> bool:
	## Advances crop growth by one day
	if current_crop == "":
		return false
	
	var crops = DataLoader.load_json_file("res://data/crops.json")
	var crop_data: Dictionary = {}
	
	for crop in crops:
		if crop.get("name") == current_crop:
			crop_data = crop
			break
	
	if crop_data.is_empty():
		return false
	
	var days_per_stage = crop_data.get("days_per_stage", 3)
	var growth_stages = crop_data.get("growth_stages", 5)
	
	crop_days_in_stage += 1
	
	if crop_days_in_stage >= days_per_stage:
		crop_growth_stage += 1
		crop_days_in_stage = 0
		
		if crop_growth_stage >= growth_stages:
			return true  # Ready to harvest
		_update_memory("grew_stage_" + str(crop_growth_stage))
		tile_changed.emit(self)
	
	return false

func harvest() -> Dictionary:
	## Harvests the crop and returns output items
	if current_crop == "" or crop_growth_stage < get_max_growth_stage():
		return {}
	
	var crops = DataLoader.load_json_file("res://data/crops.json")
	var crop_data: Dictionary = {}
	
	for crop in crops:
		if crop.get("name") == current_crop:
			crop_data = crop
			break
	
	if crop_data.is_empty():
		return {}
	
	var outputs = crop_data.get("output", [])
	var result: Dictionary = {}
	
	for output in outputs:
		result[output] = result.get(output, 0) + 1
	
	# Update memory based on harvest
	memory["last_crop"] = current_crop
	memory["years_used"] = memory.get("years_used", 0) + 1
	
	if memory["years_used"] > 5:
		memory["mood"] = "exhausted"
	elif memory["years_used"] > 3:
		memory["mood"] = "tired"
	
	# Trigger journal entry for first harvest or soil memory
	var atmosphere = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	if atmosphere and is_instance_valid(atmosphere) and atmosphere.journal_system:
		if GameManager.instance and GameManager.instance.player:
			if memory["years_used"] == 1:
				atmosphere.journal_system.add_first_harvest_entry(
					current_crop,
					GameManager.instance.player.name,
					memory["mood"],
					memory.get("last_crop", "")
				)
			
			# Add soil memory entry if heavily used
			if memory["years_used"] > 3:
				atmosphere.journal_system.add_soil_memory_entry(
					tile_position.x,
					tile_position.y,
					memory["years_used"],
					current_crop,
					memory["mood"],
					GameManager.instance.player.name
				)
	
	current_crop = ""
	crop_growth_stage = 0
	crop_days_in_stage = 0
	is_tilled = false  # Soil needs retilling after harvest
	
	_update_memory("harvested")
	tile_changed.emit(self)
	
	return result

func get_max_growth_stage() -> int:
	if current_crop == "":
		return 0
	
	var crops = DataLoader.load_json_file("res://data/crops.json")
	
	for crop in crops:
		if crop.get("name") == current_crop:
			return crop.get("growth_stages", 5)
	
	return 0

func is_ready_to_harvest() -> bool:
	return current_crop != "" and crop_growth_stage >= get_max_growth_stage()

func _update_memory(event: String):
	## Updates soil memory based on events
	# Memory system can track patterns for future mechanics
	if not memory.has("events"):
		memory["events"] = []
	
	memory["events"].append({
		"event": event,
		"day": GameManager.current_day if GameManager else 0
	})
	
	# Limit memory size
	if memory["events"].size() > 100:
		memory["events"].pop_front()

func get_tile_data() -> Dictionary:
	## Returns a dictionary representation of this tile for saving
	return {
		"x": tile_position.x,
		"y": tile_position.y,
		"soil_type": soil_type,
		"is_tilled": is_tilled,
		"current_crop": current_crop,
		"crop_growth_stage": crop_growth_stage,
		"crop_days_in_stage": crop_days_in_stage,
		"memory": memory.duplicate(true),
		"machine_affinity": machine_affinity,
		"nature_affinity": nature_affinity
	}

func load_tile_data(data: Dictionary):
	## Loads tile data from a dictionary
	tile_position = Vector2i(data.get("x", 0), data.get("y", 0))
	soil_type = data.get("soil_type", "ash_soil")
	is_tilled = data.get("is_tilled", false)
	current_crop = data.get("current_crop", "")
	crop_growth_stage = data.get("crop_growth_stage", 0)
	crop_days_in_stage = data.get("crop_days_in_stage", 0)
	memory = data.get("memory", {
		"last_crop": "",
		"years_used": 0,
		"mood": "neutral"
	})
	machine_affinity = data.get("machine_affinity", 0.5)
	nature_affinity = data.get("nature_affinity", 0.5)
	
	_load_soil_data()

