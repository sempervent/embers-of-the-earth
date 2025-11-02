extends RefCounted
class_name EncounterTable

## Manages encounter generation based on weighted tables

var encounters: Array[Dictionary] = []
var total_weight: float = 0.0

func _init():
	_load_encounters()

func _load_encounters():
	## Load encounters from JSON file
	var loader = DataLoader.new()
	encounters = loader.load_json_file("res://data/world/encounters.json")
	
	# Calculate total weight
	total_weight = 0.0
	for encounter in encounters:
		total_weight += encounter.get("weight", 1.0)

func roll_encounter() -> Dictionary:
	## Roll a random encounter based on weights
	if encounters.is_empty():
		return {}
	
	var roll = randf() * total_weight
	var cumulative = 0.0
	
	for encounter in encounters:
		cumulative += encounter.get("weight", 1.0)
		if roll <= cumulative:
			return encounter.duplicate()
	
	# Fallback to first encounter
	return encounters[0].duplicate()

func get_encounter(id: String) -> Dictionary:
	## Get a specific encounter by ID
	for encounter in encounters:
		if encounter.get("id") == id:
			return encounter.duplicate()
	return {}

