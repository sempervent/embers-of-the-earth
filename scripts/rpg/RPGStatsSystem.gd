extends Node
class_name RPGStatsSystem

## RPG-style stat system with generational inheritance

signal stat_changed(stat_name: String, new_value: float)
signal skill_milestone_reached(stat_name: String, milestone: String)

var stats: Dictionary = {
	"resolve": 10.0,
	"mechanica": 10.0,
	"soilcraft": 10.0,
	"diplomacy": 10.0,
	"vigor": 10.0
}

var progression_tracking: Dictionary = {
	"harvest_count": 0,
	"repair_count": 0,
	"trade_count": 0,
	"winter_survived": 0,
	"travel_distance": 0.0,
	"soil_memory_interactions": 0,
	"harvest_biomechanical": 0,
	"marriages": 0,
	"survived_hazards": 0
}

var stat_definitions: Dictionary = {}
var progression_definitions: Dictionary = {}

var player: Player

func _ready():
	_load_stat_definitions()
	player = GameManager.instance.player if GameManager.instance else null
	
	if player:
		# Sync with player stats
		_sync_to_player_stats()

func _load_stat_definitions():
	## Load RPG stat definitions
	var loader = DataLoader.new()
	var stat_data = loader.load_json_file("res://data/rpg/rpg_stats.json")
	
	if typeof(stat_data) == TYPE_DICTIONARY:
		stat_definitions = stat_data.get("stats", {})
		progression_definitions = stat_data.get("progression", {})

func get_stat(stat_name: String) -> float:
	## Get stat value
	return stats.get(stat_name, 10.0)

func set_stat(stat_name: String, value: float):
	## Set stat value
	var old_value = stats.get(stat_name, 10.0)
	var max_value = 100.0
	if stat_definitions.has(stat_name):
		max_value = stat_definitions[stat_name].get("max_value", 100.0)
	
	stats[stat_name] = clamp(value, 0.0, max_value)
	
	if old_value != stats[stat_name]:
		stat_changed.emit(stat_name, stats[stat_name])
		
		# Check for milestones
		_check_milestones(stat_name)

func increase_stat(stat_name: String, amount: float):
	## Increase stat by amount
	set_stat(stat_name, get_stat(stat_name) + amount)

func track_progression(progression_key: String, amount: float = 1.0):
	## Track progression toward skill milestones
	if not progression_tracking.has(progression_key):
		progression_tracking[progression_key] = 0.0
	
	progression_tracking[progression_key] = progression_tracking[progression_key] + amount
	
	# Check if milestone reached
	_check_progression_milestones(progression_key)

func _check_progression_milestones(progression_key: String):
	## Check if progression milestones are reached
	for milestone_id in progression_definitions:
		var milestone = progression_definitions[milestone_id]
		var required_key = milestone.get("threshold_key", "")
		
		if required_key == progression_key:
			var threshold = milestone.get("threshold", 0)
			var current_value = progression_tracking.get(progression_key, 0.0)
			
			if current_value >= threshold:
				_apply_milestone(milestone_id, milestone)

func _apply_milestone(milestone_id: String, milestone: Dictionary):
	## Apply milestone reward
	var stat_name = milestone.get("stat", "")
	var amount = milestone.get("amount", 1.0)
	
	if not stat_name.is_empty():
		increase_stat(stat_name, amount)
		skill_milestone_reached.emit(stat_name, milestone_id)
		
		# Add journal entry
		var atmosphere = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
		if atmosphere and atmosphere.journal_system and player:
			var description = milestone.get("description", "")
			atmosphere.journal_system.add_entry("skill_milestone", {
				"name": player.name,
				"milestone": description,
				"stat": stat_name,
				"year": GameManager.current_year,
				"generation": 1
			})

func _check_milestones(stat_name: String):
	## Check for stat-based milestones (titles, etc.)
	var title_system = get_tree().get_first_node_in_group("titles") as TitleSystem
	if title_system:
		title_system.check_title_requirements()

func inherit_stats_from_parents(parent1_stats: Dictionary, parent2_stats: Dictionary, inheritance_factors: Dictionary) -> Dictionary:
	## Calculate child stats from parent stats with inheritance factors
	var child_stats = stats.duplicate()
	
	for stat_name in child_stats:
		var parent1_value = parent1_stats.get(stat_name, 10.0)
		var parent2_value = parent2_stats.get(stat_name, 10.0)
		var inheritance_factor = inheritance_factors.get(stat_name, 0.7)
		
		# Average of parents, then apply inheritance factor
		var average = (parent1_value + parent2_value) / 2.0
		var inherited = average * inheritance_factor
		
		# Add random variation
		var variation = randf_range(-2.0, 2.0)
		child_stats[stat_name] = clamp(inherited + variation, 0.0, 100.0)
	
	return child_stats

func get_inheritance_factors() -> Dictionary:
	## Get inheritance factors for each stat
	var factors: Dictionary = {}
	
	for stat_name in stat_definitions:
		var stat_data = stat_definitions[stat_name]
		factors[stat_name] = stat_data.get("inheritance_factor", 0.7)
	
	return factors

func _sync_to_player_stats():
	## Sync RPG stats with player stats
	if not player:
		return
	
	# Map player stats to RPG stats
	var mapping = {
		"resolve": "resilience",
		"mechanica": "crafting",
		"soilcraft": "farming",
		"diplomacy": "diplomacy",
		"vigor": "travel"
	}
	
	for rpg_stat in mapping:
		var player_stat = mapping[rpg_stat]
		var player_value = player.stats.get(player_stat, 10.0)
		set_stat(rpg_stat, player_value)

func get_progression_data() -> Dictionary:
	## Get progression tracking data
	return progression_tracking.duplicate()

func get_rpg_stats() -> Dictionary:
	## Get all RPG stats
	return stats.duplicate()

