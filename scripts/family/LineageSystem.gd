extends Node
class_name LineageSystem

## Manages marriage contracts, lineage, and child generation

signal marriage_proposed(contract: Dictionary)
signal marriage_accepted(contract: Dictionary, spouse_data: Dictionary)
signal marriage_declined(contract: Dictionary)
signal child_born(child_data: Dictionary)
signal generation_advanced(new_generation: int)

var active_contracts: Array[Dictionary] = []
var completed_contracts: Array[Dictionary] = []
var lineage_tree: Dictionary = {}

var player: Player
var game_manager: GameManager

func _ready():
	game_manager = GameManager.instance
	if game_manager:
		player = game_manager.player
	
	if not player:
		push_error("Player not found!")

func propose_marriage(faction_id: String, terms_id: String = "") -> Dictionary:
	## Propose marriage to a faction
	var loader = DataLoader.new()
	var terms_list = loader.load_json_file("res://data/marriage_terms.json")
	
	var contract: Dictionary = {}
	
	# Find matching contract
	for terms in terms_list:
		if terms.get("faction") == faction_id:
			contract = terms.duplicate()
			break
	
	if contract.is_empty():
		push_error("No marriage terms found for faction: " + faction_id)
		return {}
	
	# Generate spouse data
	var spouse_data = _generate_spouse(faction_id, contract)
	contract["spouse"] = spouse_data
	
	# Add obligations tracking
	contract["obligations_fulfilled"] = {}
	contract["years_active"] = 0
	
	# Store contract
	active_contracts.append(contract)
	
	marriage_proposed.emit(contract)
	return contract

func accept_marriage(contract: Dictionary) -> bool:
	## Accept a marriage contract
	if not player:
		return false
	
	# Check if player can fulfill dowry
	if not _can_fulfill_dowry(contract):
		push_warning("Cannot fulfill dowry requirements!")
		return false
	
	# Fulfill dowry
	_fulfill_dowry(contract)
	
	# Apply benefits
	_apply_benefits(contract)
	
	# Move to completed contracts
	active_contracts.erase(contract)
	completed_contracts.append(contract)
	
	# Generate child after marriage (1 year later)
	var spouse = contract.get("spouse", {})
	_schedule_child_birth(spouse, contract)
	
	marriage_accepted.emit(contract, spouse)
	
	# Add journal entry
	var atmosphere = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	if atmosphere and atmosphere.journal_system:
		var spouse_name = spouse.get("name", "Unknown")
		var faction_name = contract.get("faction", "Unknown")
		atmosphere.journal_system.add_marriage_entry(
			spouse_name,
			faction_name,
			player.name,
			""
		)
	
	return true

func decline_marriage(contract: Dictionary):
	## Decline a marriage contract
	active_contracts.erase(contract)
	marriage_declined.emit(contract)

func _can_fulfill_dowry(contract: Dictionary) -> bool:
	## Check if player can fulfill dowry requirements
	if not player:
		return false
	
	var dowry = contract.get("dowry", {})
	var items = dowry.get("items", {})
	
	var inventory = player.get_inventory()
	for item in items:
		var required = items[item]
		var available = inventory.get(item, 0)
		if available < required:
			return false
	
	return true

func _fulfill_dowry(contract: Dictionary):
	## Fulfill dowry requirements
	var dowry = contract.get("dowry", {})
	var items = dowry.get("items", {})
	
	for item in items:
		var quantity = items[item]
		player.remove_item(item, quantity)

func _apply_benefits(contract: Dictionary):
	## Apply marriage benefits
	var benefits = contract.get("benefits", {})
	
	# Tech benefits
	if benefits.has("tech"):
		var tech_items = benefits.get("tech", [])
		for tech in tech_items:
			# Would unlock technology
			pass
	
	# Seeds
	if benefits.has("seeds"):
		var seeds = benefits.get("seeds", [])
		for seed in seeds:
			player.add_item(seed, 5)
	
	# Reputation
	if benefits.has("reputation"):
		var rep = benefits.get("reputation", {})
		for faction in rep:
			if not player.faction_relations.has(faction):
				player.faction_relations[faction] = 0
			player.faction_relations[faction] += rep[faction]
	
	# Knowledge (would unlock features)
	if benefits.has("knowledge"):
		pass
	
	# Security/services (would activate features)
	if benefits.has("security"):
		pass
	if benefits.has("trade"):
		pass

func process_year_tick():
	## Process obligations and events each year
	for contract in completed_contracts:
		contract["years_active"] = contract.get("years_active", 0) + 1
		
		# Check obligations
		var obligations = contract.get("obligations", {})
		
		# Tribute
		if obligations.has("tribute"):
			var tribute = obligations.get("tribute", {})
			_check_tribute(tribute, contract)
		
		# Apprenticeship
		if obligations.has("apprenticeship_years"):
			var years = obligations.get("apprenticeship_years", 0)
			if contract["years_active"] < years:
				# Still in apprenticeship
				pass
		
		# Military service
		if obligations.has("military_service"):
			var years = obligations.get("military_service", 0)
			if contract["years_active"] < years:
				# Still in service
				pass

func _check_tribute(tribute: Dictionary, contract: Dictionary):
	## Check if tribute obligations are met
	var inventory = player.get_inventory()
	var missing_items: Array[String] = []
	
	for item in tribute:
		var required = tribute[item]
		var available = inventory.get(item, 0)
		if available < required:
			missing_items.append(item)
	
	if not missing_items.is_empty():
		# Tribute not met - reputation penalty
		var faction = contract.get("faction", "")
		if player.faction_relations.has(faction):
			player.faction_relations[faction] = max(-50, player.faction_relations[faction] - 5)
	else:
		# Fulfill tribute
		for item in tribute:
			var quantity = tribute[item]
			player.remove_item(item, quantity)
		
		# Reputation bonus
		var faction = contract.get("faction", "")
		if player.faction_relations.has(faction):
			player.faction_relations[faction] = min(100, player.faction_relations[faction] + 2)

func _generate_spouse(faction_id: String, contract: Dictionary) -> Dictionary:
	## Generate spouse data procedurally
	var traits_loader = DataLoader.new()
	var all_traits = traits_loader.load_json_file("res://data/traits.json")
	
	# Faction-based trait selection
	var faction_traits = _get_faction_traits(faction_id)
	var spouse_traits: Array[String] = []
	
	# Select 2-3 traits
	var trait_count = randi_range(2, 3)
	for i in trait_count:
		var trait_options = faction_traits if not faction_traits.is_empty() else ["stubborn", "diplomatic", "wise"]
		var trait = trait_options[randi() % trait_options.size()]
		if not spouse_traits.has(trait):
			spouse_traits.append(trait)
	
	# Generate name (would use name generator)
	var spouse_name = _generate_name(faction_id)
	
	# Generate stats influenced by faction
	var spouse_stats = _generate_spouse_stats(faction_id)
	
	# Generate appearance seed (for sprite generation)
	var appearance_seed = randi()
	
	return {
		"name": spouse_name,
		"faction": faction_id,
		"traits": spouse_traits,
		"stats": spouse_stats,
		"age": randi_range(18, 35),
		"appearance_seed": appearance_seed
	}

func _get_faction_traits(faction_id: String) -> Array[String]:
	## Get likely traits for faction
	match faction_id:
		"machinists":
			return ["mechanically_gifted", "inventive", "strong"]
		"root_keepers":
			return ["green_thumb", "wise", "diplomatic"]
		"rusted_brotherhood":
			return ["strong", "loyal", "stubborn"]
		"ash_caravans":
			return ["wanderer", "diplomatic", "wise"]
		_:
			return ["diplomatic", "wise"]

func _generate_name(faction_id: String) -> String:
	## Generate a name based on faction
	# Simplified name generation
	var first_names = ["Elena", "Marcus", "Lydia", "Theo", "Iris", "Caleb"]
	var last_names = ["Coalroot", "Steamforge", "Rootbound", "Brasswood", "Ironleaf"]
	
	var first = first_names[randi() % first_names.size()]
	var last = last_names[randi() % last_names.size()]
	
	return first + " " + last

func _generate_spouse_stats(faction_id: String) -> Dictionary:
	## Generate spouse stats based on faction
	var base_stats = {
		"strength": 10,
		"farming": 10,
		"crafting": 10,
		"diplomacy": 10,
		"resilience": 10,
		"travel": 5
	}
	
	# Faction bonuses
	match faction_id:
		"machinists":
			base_stats["crafting"] += 5
			base_stats["strength"] += 2
		"root_keepers":
			base_stats["farming"] += 5
			base_stats["diplomacy"] += 2
		"rusted_brotherhood":
			base_stats["strength"] += 5
			base_stats["resilience"] += 3
		"ash_caravans":
			base_stats["travel"] += 5
			base_stats["diplomacy"] += 3
	
	return base_stats

func _schedule_child_birth(spouse: Dictionary, contract: Dictionary):
	## Schedule child birth after marriage
	# Children are born 1-2 years after marriage
	var birth_delay = randi_range(1, 2)
	
	# Would schedule with game manager
	# For now, simplified: check in process_year_tick
	contract["child_due_year"] = GameManager.current_year + birth_delay
	contract["spouse"] = spouse

func check_child_births():
	## Check if any children should be born this year
	for contract in completed_contracts:
		if contract.has("child_due_year"):
			if contract["child_due_year"] <= GameManager.current_year:
				var spouse = contract.get("spouse", {})
				_generate_child(spouse, contract)
				contract.erase("child_due_year")

func _generate_child(spouse: Dictionary, contract: Dictionary):
	## Generate a child from parents
	var child_traits: Array[String] = []
	var child_stats: Dictionary = {}
	
	# Inherit traits from both parents
	var parent_traits = player.traits.duplicate()
	var spouse_traits = spouse.get("traits", [])
	
	# Each parent contributes 1-2 traits
	var parent_trait_count = min(2, parent_traits.size())
	var spouse_trait_count = min(2, spouse_traits.size())
	
	for i in range(parent_trait_count):
		if not parent_traits.is_empty():
			var trait = parent_traits[randi() % parent_traits.size()]
			if not child_traits.has(trait):
				child_traits.append(trait)
	
	for i in range(spouse_trait_count):
		if not spouse_traits.is_empty():
			var trait = spouse_traits[randi() % spouse_traits.size()]
			if not child_traits.has(trait):
				child_traits.append(trait)
	
	# Generate stats (average of parents + random)
	var parent_stats = player.stats.duplicate()
	var spouse_stats = spouse.get("stats", {})
	
	for stat in parent_stats:
		var parent_val = parent_stats[stat]
		var spouse_val = spouse_stats.get(stat, parent_val)
		var average = (parent_val + spouse_val) / 2.0
		child_stats[stat] = average + randf_range(-2, 2)
		child_stats[stat] = max(1, child_stats[stat])  # Minimum 1
	
	# Generate name and appearance
	var child_name = _generate_child_name(spouse.get("name", ""))
	var appearance_seed = randi()
	
	var child_data = {
		"name": child_name,
		"age": 0,
		"traits": child_traits,
		"stats": child_stats,
		"generation": 1,  # Would track actual generation
		"parent1": player.name,
		"parent2": spouse.get("name", ""),
		"appearance_seed": appearance_seed
	}
	
	# Add to player's children
	player.add_child(child_data)
	
	child_born.emit(child_data)
	
	# Add journal entry
	var atmosphere = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	if atmosphere and atmosphere.journal_system:
		atmosphere.journal_system.add_first_child_entry(child_name, player.name)

func _generate_child_name(spouse_name: String) -> String:
	## Generate child name
	var first_names = ["Elias", "Maya", "Owen", "Sage", "Rex", "Iris"]
	var last_names = ["Coalroot", "Steamforge", "Rootbound"]
	
	var first = first_names[randi() % first_names.size()]
	var last = last_names[randi() % last_names.size()]
	
	return first + " " + last

func handle_player_death(successor: Dictionary):
	## Handle succession when player dies
	# Successor is a child
	var new_generation = successor.get("generation", 1)
	
	if new_generation > 1:
		generation_advanced.emit(new_generation)
		
		# Update lineage tree
		if not lineage_tree.has("generations"):
			lineage_tree["generations"] = []
		lineage_tree["generations"].append({
			"generation": new_generation,
			"successor": successor,
			"year": GameManager.current_year
		})

func get_lineage_data() -> Dictionary:
	## Get lineage tree data
	return lineage_tree.duplicate()

func get_active_contracts() -> Array[Dictionary]:
	## Get active marriage contracts
	return active_contracts.duplicate()

func get_completed_contracts() -> Array[Dictionary]:
	## Get completed marriage contracts
	return completed_contracts.duplicate()

