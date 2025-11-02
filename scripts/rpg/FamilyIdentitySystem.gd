extends Node
class_name FamilyIdentitySystem

## Manages family crest, banner, and motto

signal family_identity_created(identity: Dictionary)
signal motto_updated(new_motto: String)

var family_name: String = ""
var motto: String = ""
var crest_elements: Array[String] = []
var crest_data: Dictionary = {}
var banner_color: Color = Color(0.8, 0.6, 0.4)  # Copper

var origin: Dictionary = {}

func _ready():
	add_to_group("family_identity")

func initialize_family(character_data: Dictionary):
	## Initialize family identity from character creation
	family_name = character_data.get("family_name", "Coalroot")
	
	var origin_id = character_data.get("origin", "")
	var loader = DataLoader.new()
	var origins = loader.load_json_file("res://data/family_identity/origins.json")
	
	for origin_data in origins:
		if origin_data.get("id") == origin_id:
			origin = origin_data
			motto = origin_data.get("motto", "We Endure")
			crest_elements = origin_data.get("crest_elements", []).duplicate()
			break
	
	# Generate crest
	_generate_crest(character_data)
	
	family_identity_created.emit({
		"family_name": family_name,
		"motto": motto,
		"crest_elements": crest_elements,
		"banner_color": banner_color
	})

func _generate_crest(character_data: Dictionary):
	## Generate family crest based on traits and origin
	crest_elements = origin.get("crest_elements", []).duplicate()
	
	# Add elements based on traits
	var trait1 = character_data.get("trait1", "")
	var trait2 = character_data.get("trait2", "")
	
	# Would add crest elements based on traits
	# For example: "ironblood" adds gear element
	
	# Generate crest data
	crest_data = {
		"elements": crest_elements,
		"color": banner_color,
		"pattern": _generate_crest_pattern()
	}

func _generate_crest_pattern() -> String:
	## Generate crest pattern
	# Simplified: return pattern name
	var patterns = ["quartered", "pale", "fess", "bend", "chevron"]
	return patterns[randi() % patterns.size()]

func get_crest_texture() -> Texture2D:
	## Generate crest texture (would use procedural generation)
	# Placeholder: would generate pixel art crest
	return null

func get_motto() -> String:
	## Get family motto
	return motto

func set_motto(new_motto: String):
	## Set family motto (can change over time)
	motto = new_motto
	motto_updated.emit(new_motto)
	
	# Add journal entry
	var atmosphere = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	if atmosphere and atmosphere.journal_system:
		var player_name = GameManager.instance.player.name if GameManager.instance and GameManager.instance.player else "Farmer"
		atmosphere.journal_system.add_entry("motto_changed", {
			"name": player_name,
			"old_motto": motto,
			"new_motto": new_motto,
			"year": GameManager.current_year,
			"generation": 1
		})

func get_family_identity_data() -> Dictionary:
	## Get family identity for saving
	return {
		"family_name": family_name,
		"motto": motto,
		"crest_elements": crest_elements.duplicate(),
		"banner_color": banner_color.to_html(),
		"origin": origin.get("id", "")
	}

func load_family_identity_data(data: Dictionary):
	## Load family identity from save
	family_name = data.get("family_name", "Coalroot")
	motto = data.get("motto", "We Endure")
	crest_elements = data.get("crest_elements", []).duplicate()
	
	var color_hex = data.get("banner_color", "#CD853F")
	banner_color = Color(color_hex)

