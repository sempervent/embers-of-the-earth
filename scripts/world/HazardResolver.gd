extends Node
class_name HazardResolver

## Resolves travel hazards with choice-based outcomes

signal hazard_resolved(hazard_id: String, choice_id: String, success: bool)
signal choice_presented(hazard: Dictionary, available_choices: Array)

var hazards: Array[Dictionary] = []
var player: Player

func _ready():
	_load_hazards()
	player = GameManager.instance.player if GameManager.instance else null

func _load_hazards():
	## Load hazards from JSON
	var loader = DataLoader.new()
	hazards = loader.load_json_file("res://data/world/hazards.json")

func get_hazard(hazard_id: String) -> Dictionary:
	## Get hazard by ID
	for hazard in hazards:
		if hazard.get("id") == hazard_id:
			return hazard.duplicate()
	return {}

func resolve_hazard(hazard_id: String, choice_id: String) -> Dictionary:
	## Resolve a hazard with a choice
	var hazard = get_hazard(hazard_id)
	if hazard.is_empty():
		return {}
	
	var choices = hazard.get("choices", [])
	var selected_choice: Dictionary = {}
	
	for choice in choices:
		if choice.get("id") == choice_id:
			selected_choice = choice
			break
	
	if selected_choice.is_empty():
		return {}
	
	# Check if choice requirements are met
	if not _check_choice_requirements(selected_choice):
		return {"error": "Requirements not met"}
	
	# Roll for success
	var success_chance = selected_choice.get("success_chance", 1.0)
	var success = randf() < success_chance
	
	var outcomes = selected_choice.get("success" if success else "failure", {})
	
	# Apply outcomes
	_apply_outcomes(outcomes)
	
	hazard_resolved.emit(hazard_id, choice_id, success)
	
	return {
		"success": success,
		"outcomes": outcomes
	}

func get_available_choices(hazard_id: String) -> Array[Dictionary]:
	## Get choices available to player for a hazard
	var hazard = get_hazard(hazard_id)
	if hazard.is_empty():
		return []
	
	var choices = hazard.get("choices", [])
	var available: Array[Dictionary] = []
	
	for choice in choices:
		if _check_choice_requirements(choice):
			available.append(choice)
	
	# If no choices available, return all (player must pick one, even if can't succeed)
	if available.is_empty():
		return choices
	
	return available

func present_hazard(hazard_id: String):
	## Present hazard to player with available choices
	var hazard = get_hazard(hazard_id)
	if hazard.is_empty():
		return
	
	var available_choices = get_available_choices(hazard_id)
	choice_presented.emit(hazard, available_choices)

func _check_choice_requirements(choice: Dictionary) -> bool:
	## Check if player meets choice requirements
	if not player:
		return false
	
	var requires = choice.get("requires", {})
	
	# Check traits
	if requires.has("traits"):
		var required_traits = requires.get("traits", [])
		var player_traits = player.traits.duplicate()
		
		for trait in required_traits:
			if not player_traits.has(trait):
				# Check if trait name contains substring (for flexible matching)
				var found = false
				for player_trait in player_traits:
					if trait in player_trait or player_trait in trait:
						found = true
						break
				if not found:
					return false
	
	# Check items
	if requires.has("items"):
		var required_items = requires.get("items", {})
		var inventory = player.get_inventory()
		
		for item in required_items:
			var required = required_items[item]
			var available = inventory.get(item, 0)
			if available < required:
				return false
	
	# Check stats (future)
	if requires.has("stats"):
		var required_stats = requires.get("stats", {})
		for stat in required_stats:
			var required = required_stats[stat]
			var player_stat = player.stats.get(stat, 0)
			if player_stat < required:
				return false
	
	return true

func _apply_outcomes(outcomes: Dictionary):
	## Apply choice outcomes to player
	if not player:
		return
	
	# Lose items
	if outcomes.has("lose_items"):
		var items = outcomes.get("lose_items", {})
		if typeof(items) == TYPE_DICTIONARY:
			for item in items:
				player.remove_item(item, items[item])
		elif typeof(items) == TYPE_ARRAY:
			for item in items:
				player.remove_item(item, randf_range(1, 3))
	
	# Gain items
	if outcomes.has("gain_items"):
		var items = outcomes.get("gain_items", {})
		for item in items:
			player.add_item(item, items[item])
	
	# Injury
	if outcomes.has("injury"):
		var injury = outcomes.get("injury")
		player.add_injury(injury)
	
	# Heal injury
	if outcomes.get("rest", false):
		if not player.injuries.is_empty():
			player.injuries.pop_back()
	
	# Reputation
	if outcomes.has("reputation_gain"):
		var gain = outcomes.get("reputation_gain")
		# Would update faction reputation
		pass
	
	if outcomes.has("reputation_loss"):
		var loss = outcomes.get("reputation_loss")
		# Would update faction reputation
		pass
	
	# Damage (future: health system)
	if outcomes.has("damage"):
		var damage = outcomes.get("damage")
		# Would reduce player health
		pass
	
	# Lose days (for travel)
	if outcomes.has("lose_days"):
		var days = outcomes.get("lose_days")
		# Would add to travel days
		pass

