extends Node
class_name HeirloomSystem

## Manages heirlooms passed through generations

signal heirloom_acquired(heirloom_id: String)
signal heirloom_lost(heirloom_id: String)
signal heirloom_used(heirloom_id: String)

var owned_heirlooms: Dictionary = {}  # heirloom_id -> HeirloomData
var lost_heirlooms: Array[String] = []
var heirloom_definitions: Array[Dictionary] = []

var player: Player
var atmosphere_manager: AtmosphereManager

func _ready():
	_load_heirlooms()
	_initialize_starting_heirlooms()
	
	player = GameManager.instance.player if GameManager.instance else null
	atmosphere_manager = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager

func _load_heirlooms():
	## Load heirloom definitions
	var loader = DataLoader.new()
	heirloom_definitions = loader.load_json_file("res://data/heirlooms/heirlooms.json")

func _initialize_starting_heirlooms():
	## Give starting heirlooms to first generation
	var starting_heirlooms = ["first_farmer_letter", "cracked_music_locket", "heirloom_seeds"]
	
	for heirloom_id in starting_heirlooms:
		acquire_heirloom(heirloom_id, 1)

func acquire_heirloom(heirloom_id: String, generation: int):
	## Acquire an heirloom
	if lost_heirlooms.has(heirloom_id):
		# Heirloom was lost, cannot be regained
		return
	
	var definition = _get_heirloom_definition(heirloom_id)
	if definition.is_empty():
		push_error("Heirloom not found: " + heirloom_id)
		return
	
	var heirloom_data = definition.duplicate()
	heirloom_data["generation_acquired"] = generation
	heirloom_data["acquired_year"] = GameManager.current_year
	
	owned_heirlooms[heirloom_id] = heirloom_data
	
	heirloom_acquired.emit(heirloom_id)
	
	# Add journal entry
	if atmosphere_manager and atmosphere_manager.journal_system:
		var player_name = player.name if player else "Farmer"
		var name = heirloom_data.get("name", "")
		atmosphere_manager.journal_system.add_entry("heirloom_acquired", {
			"name": player_name,
			"heirloom": name,
			"text": "The heirloom has been passed down: " + name + ". History lives in our hands.",
			"year": GameManager.current_year,
			"generation": generation
		})

func lose_heirloom(heirloom_id: String, reason: String = ""):
	## Lose an heirloom
	if not owned_heirlooms.has(heirloom_id):
		return
	
	var heirloom = owned_heirlooms[heirloom_id]
	var heirloom_name = heirloom.get("name", "")
	
	owned_heirlooms.erase(heirloom_id)
	lost_heirlooms.append(heirloom_id)
	
	heirloom_lost.emit(heirloom_id)
	
	# Add journal entry
	if atmosphere_manager and atmosphere_manager.journal_system:
		var player_name = player.name if player else "Farmer"
		var entry_text = "Lost the heirloom: " + heirloom_name
		if not reason.is_empty():
			entry_text += ". " + reason
		entry_text += ". The weight of the loss is heavy."
		
		atmosphere_manager.journal_system.add_entry("heirloom_lost", {
			"name": player_name,
			"heirloom": heirloom_name,
			"text": entry_text,
			"year": GameManager.current_year,
			"generation": 1
		})

func use_heirloom(heirloom_id: String) -> Dictionary:
	## Use an heirloom (for special effects)
	if not owned_heirlooms.has(heirloom_id):
		return {}
	
	var heirloom = owned_heirlooms[heirloom_id]
	var effects = heirloom.get("effects", {})
	
	# Apply effects
	if player:
		_apply_heirloom_effects(effects)
	
	heirloom_used.emit(heirloom_id)
	
	# Special effects
	var special = heirloom.get("special", "")
	if special == "Plays ancestral theme when opened":
		_play_ancestral_music()
	
	return effects

func _apply_heirloom_effects(effects: Dictionary):
	## Apply heirloom effects to player
	if not player:
		return
	
	# Stat bonuses
	if effects.has("farming_bonus"):
		player.stats["farming"] = player.stats.get("farming", 10) + effects["farming_bonus"]
	
	if effects.has("crafting_bonus"):
		player.stats["crafting"] = player.stats.get("crafting", 10) + effects["crafting_bonus"]
	
	if effects.has("soil_knowledge"):
		# Would unlock soil knowledge
		pass
	
	# Faction penalties (from shame)
	if effects.has("faction_penalty"):
		var penalty = effects["faction_penalty"]
		# Would apply to all factions
		pass

func _play_ancestral_music():
	## Play ancestral theme from locket
	if atmosphere_manager and atmosphere_manager.procedural_music:
		# Would trigger special music layer
		atmosphere_manager.procedural_music.update_condition("ancestral_memory", true)

func get_heirloom(heirloom_id: String) -> Dictionary:
	## Get heirloom data
	return owned_heirlooms.get(heirloom_id, {})

func get_owned_heirlooms() -> Array[Dictionary]:
	## Get all owned heirlooms
	return owned_heirlooms.values().duplicate()

func get_lost_heirlooms() -> Array[String]:
	## Get list of lost heirloom IDs
	return lost_heirlooms.duplicate()

func _get_heirloom_definition(heirloom_id: String) -> Dictionary:
	## Get heirloom definition by ID
	for heirloom in heirloom_definitions:
		if heirloom.get("id") == heirloom_id:
			return heirloom.duplicate()
	return {}

func pass_to_next_generation(successor: Dictionary):
	## Pass heirlooms to next generation
	var new_generation = successor.get("generation", 1)
	
	for heirloom_id in owned_heirlooms:
		var heirloom = owned_heirlooms[heirloom_id]
		heirloom["generation_acquired"] = new_generation
		
		# Add journal entry about inheritance
		if atmosphere_manager and atmosphere_manager.journal_system:
			var heirloom_name = heirloom.get("name", "")
			var successor_name = successor.get("name", "")
			atmosphere_manager.journal_system.add_entry("heirloom_inherited", {
				"name": successor_name,
				"heirloom": heirloom_name,
				"text": "The heirloom " + heirloom_name + " passes to " + successor_name + ". The bloodline continues.",
				"year": GameManager.current_year,
				"generation": new_generation
			})

func get_heirloom_data() -> Dictionary:
	## Get heirloom state for saving
	return {
		"owned": owned_heirlooms.duplicate(true),
		"lost": lost_heirlooms.duplicate()
	}

func load_heirloom_data(data: Dictionary):
	## Load heirloom state from save
	owned_heirlooms = data.get("owned", {}).duplicate(true)
	lost_heirlooms = data.get("lost", []).duplicate()

