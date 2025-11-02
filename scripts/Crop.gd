extends RefCounted
class_name Crop

## Represents a crop type with its properties and requirements

var name: String
var growth_stages: int
var requires: Array[String]
var output: Array[String]
var likes: Array[String]
var hates: Array[String]
var days_per_stage: int
var biomechanical: bool
var description: String

func _init(data: Dictionary):
	name = data.get("name", "")
	growth_stages = data.get("growth_stages", 5)
	requires = data.get("requires", []).duplicate()
	output = data.get("output", []).duplicate()
	likes = data.get("likes", []).duplicate()
	hates = data.get("hates", []).duplicate()
	days_per_stage = data.get("days_per_stage", 3)
	biomechanical = data.get("biomechanical", false)
	description = data.get("description", "")

static func load_crop(crop_name: String) -> Crop:
	## Loads a crop by name from the database
	var loader = DataLoader.new()
	var crops = loader.load_json_file("res://data/crops.json")
	
	for crop_data in crops:
		if crop_data.get("name") == crop_name:
			return Crop.new(crop_data)
	
	push_error("Crop not found: " + crop_name)
	return null

static func get_all_crops() -> Array[Crop]:
	## Returns all available crops
	var loader = DataLoader.new()
	var crops_data = loader.load_json_file("res://data/crops.json")
	var crops: Array[Crop] = []
	
	for crop_data in crops_data:
		crops.append(Crop.new(crop_data))
	
	return crops

func check_soil_compatibility(soil_type: String) -> float:
	## Returns compatibility score: 1.0 = perfect, 0.5 = neutral, 0.0 = bad
	if hates.has(soil_type):
		return 0.0
	if likes.has(soil_type):
		return 1.0
	return 0.5

