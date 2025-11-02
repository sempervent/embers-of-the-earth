extends Node
class_name TitleSystem

## Manages earned titles and their effects

signal title_earned(title_id: String, title_name: String)
signal title_lost(title_id: String)

var earned_titles: Array[String] = []
var title_definitions: Array[Dictionary] = []

var rpg_stats: RPGStatsSystem
var player: Player
var game_manager: GameManager

func _ready():
	_load_titles()
	rpg_stats = get_tree().get_first_node_in_group("rpg_stats") as RPGStatsSystem
	game_manager = GameManager.instance
	if game_manager:
		player = game_manager.player
	
	add_to_group("titles")

func _load_titles():
	## Load title definitions
	var loader = DataLoader.new()
	title_definitions = loader.load_json_file("res://data/rpg/titles.json")

func check_title_requirements():
	## Check if player qualifies for any titles
	for title in title_definitions:
		var title_id = title.get("id", "")
		if earned_titles.has(title_id):
			continue
		
		if _meets_requirements(title):
			earn_title(title_id)

func _meets_requirements(title: Dictionary) -> bool:
	## Check if player meets title requirements
	var requirements = title.get("requirements", {})
	
	# Stat requirements
	for stat_name in ["resolve", "mechanica", "soilcraft", "diplomacy", "vigor"]:
		if requirements.has(stat_name):
			var required = requirements.get(stat_name, 0)
			var current = rpg_stats.get_stat(stat_name) if rpg_stats else 10.0
			if current < required:
				return false
	
	# Progression requirements
	var progression = rpg_stats.get_progression_data() if rpg_stats else {}
	
	if requirements.has("harvest_count"):
		var current = progression.get("harvest_count", 0)
		if current < requirements.get("harvest_count", 0):
			return false
	
	if requirements.has("broken_contracts"):
		# Would check lineage system
		pass
	
	if requirements.has("soil_memory_interactions"):
		var current = progression.get("soil_memory_interactions", 0)
		if current < requirements.get("soil_memory_interactions", 0):
			return false
	
	if requirements.has("generation"):
		# Would check current generation
		pass
	
	if requirements.has("order_entropy"):
		var entropy = get_tree().get_first_node_in_group("entropy") as EntropySystem
		if entropy:
			if entropy.order_level < requirements.get("order_entropy", 0):
				return false
	
	if requirements.has("marriages"):
		var current = progression.get("marriages", 0)
		if current < requirements.get("marriages", 0):
			return false
	
	return true

func earn_title(title_id: String):
	## Earn a title
	if earned_titles.has(title_id):
		return
	
	var title = _get_title(title_id)
	if title.is_empty():
		return
	
	earned_titles.append(title_id)
	_apply_title_effects(title)
	
	var title_name = title.get("name", title_id)
	title_earned.emit(title_id, title_name)
	
	# Add journal entry
	var atmosphere = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	if atmosphere and atmosphere.journal_system and player:
		atmosphere.journal_system.add_entry("title_earned", {
			"name": player.name,
			"title": title_name,
			"description": title.get("description", ""),
			"year": GameManager.current_year,
			"generation": 1
		})

func _apply_title_effects(title: Dictionary):
	## Apply title effects
	var effects = title.get("effects", {})
	
	if rpg_stats:
		# Stat bonuses
		for stat_name in ["resolve", "mechanica", "soilcraft", "diplomacy", "vigor"]:
			var bonus_key = stat_name + "_bonus"
			if effects.has(bonus_key):
				rpg_stats.increase_stat(stat_name, effects[bonus_key])
		
		# Soil bonuses
		if effects.has("soil_mood_bonus"):
			# Would apply to tiles
			pass
		if effects.has("crop_yield_bonus"):
			# Would apply to harvests
			pass
	
	if player:
		# Faction opinion bonuses
		if effects.has("faction_opinions"):
			var opinions = effects.get("faction_opinions", {})
			for faction in opinions:
				if not player.faction_relations.has(faction):
					player.faction_relations[faction] = 0
				player.faction_relations[faction] += opinions[faction]

func _get_title(title_id: String) -> Dictionary:
	## Get title definition by ID
	for title in title_definitions:
		if title.get("id") == title_id:
			return title
	return {}

func get_title_display_string() -> String:
	## Get display string for all titles
	if earned_titles.is_empty():
		return ""
	
	var display = []
	for title_id in earned_titles:
		var title = _get_title(title_id)
		if not title.is_empty():
			display.append(title.get("name", title_id))
	
	return ", ".join(display)

func has_title(title_id: String) -> bool:
	## Check if player has a title
	return earned_titles.has(title_id)

