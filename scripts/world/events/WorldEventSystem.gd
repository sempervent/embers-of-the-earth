extends Node
class_name WorldEventSystem

## Manages dynamic world events that change the game world

signal world_event_triggered(event_id: String, event_data: Dictionary)
signal settlement_changed(settlement_id: String, change_type: String)

var event_definitions: Array[Dictionary] = []
var triggered_events: Array[String] = []

var rumor_system: RumorSystem
var npc_system: NPCSystem
var atmosphere_manager: AtmosphereManager
var game_manager: GameManager

func _ready():
	_load_events()
	rumor_system = get_tree().get_first_node_in_group("rumor_system") as RumorSystem
	npc_system = get_tree().get_first_node_in_group("npc_system") as NPCSystem
	atmosphere_manager = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	game_manager = GameManager.instance
	
	# Start event checking
	_check_events()

func _load_events():
	## Load world event definitions
	var loader = DataLoader.new()
	event_definitions = loader.load_json_file("res://data/world/events/world_events.json")

func _check_events():
	## Check for events that should trigger
	for event in event_definitions:
		var event_id = event.get("id", "")
		if event_id.is_empty() or triggered_events.has(event_id):
			continue
		
		if _should_trigger_event(event):
			_trigger_event(event)

func _should_trigger_event(event: Dictionary) -> bool:
	## Check if event should trigger based on conditions
	var conditions = event.get("trigger_conditions", {})
	
	# Year requirement
	if conditions.has("min_year"):
		if GameManager.current_year < conditions.get("min_year", 0):
			return false
	
	# Faction requirement
	if conditions.has("faction_type"):
		# Would check faction state
		pass
	
	# Chance per year
	if conditions.has("chance_per_year"):
		if randf() > conditions.get("chance_per_year", 0.0):
			return false
	
	# Requires travel
	if conditions.get("requires_travel", false):
		# Would check if player has traveled recently
		pass
	
	# Requires entropy
	if conditions.has("requires_entropy"):
		var entropy = get_tree().get_first_node_in_group("entropy") as EntropySystem
		if not entropy:
			return false
		
		var path = conditions.get("requires_entropy")
		var threshold = conditions.get("entropy_threshold", 0)
		
		var level = entropy.order_level if path == "order" else entropy.wild_level
		if level < threshold:
			return false
	
	# Generation requirement
	if conditions.has("generation"):
		var lineage = get_tree().get_first_node_in_group("lineage") as LineageSystem
		if not lineage:
			return false
		# Would check current generation
		pass
	
	return true

func _trigger_event(event: Dictionary):
	## Trigger a world event
	var event_id = event.get("id", "")
	var effects = event.get("effects", {})
	var rumors = event.get("rumors", [])
	var journal_entries = event.get("journal_entries", [])
	
	triggered_events.append(event_id)
	world_event_triggered.emit(event_id, event)
	
	# Apply effects
	_apply_event_effects(effects, event)
	
	# Generate rumors
	if not rumors.is_empty():
		_generate_event_rumors(rumors, effects)
	
	# Add journal entries
	if not journal_entries.is_empty():
		_add_event_journal_entries(journal_entries, effects)

func _apply_event_effects(effects: Dictionary, event: Dictionary):
	## Apply event effects to game world
	# Settlement changes
	if effects.has("settlement"):
		var settlement_id = effects.get("settlement")
		if settlement_id == "random":
			settlement_id = _get_random_settlement()
		
		if effects.has("price_multiplier"):
			var multiplier = effects.get("price_multiplier", 1.0)
			_adjust_settlement_prices(settlement_id, multiplier)
		
		if effects.has("stock_reduction"):
			var reduction = effects.get("stock_reduction", 0.0)
			_reduce_settlement_stock(settlement_id, reduction)
		
		if effects.has("spawn_refugees"):
			_spawn_refugees(settlement_id, effects.get("refugee_count", 0))
	
	# Faction changes
	if effects.has("faction"):
		var faction_id = effects.get("faction")
		if faction_id == "random":
			faction_id = _get_random_faction()
		
		if effects.get("void_contracts", false):
			_void_faction_contracts(faction_id)
		
		if effects.get("reputation_wipe", false):
			_wipe_faction_reputation(faction_id)
	
	# Heirloom loss
	if effects.get("lose_heirloom", false):
		var heirloom_system = get_tree().get_first_node_in_group("heirlooms") as HeirloomSystem
		if heirloom_system:
			var heirloom_type = effects.get("heirloom_type", "")
			heirloom_system.lose_heirloom(heirloom_type)
	
	# Player reputation
	if effects.has("player_reputation_loss"):
		var loss = effects.get("player_reputation_loss", 0)
		if game_manager and game_manager.player:
			# Would reduce general reputation or faction-specific
			pass
	
	# Settlement transformation
	if effects.has("transform_soil"):
		var soil_type = effects.get("transform_soil")
		var settlement_id = effects.get("settlement", "")
		_transform_settlement_soil(settlement_id, soil_type)

func _generate_event_rumors(rumors: Array[String], effects: Dictionary):
	## Generate rumors from event
	if not rumor_system:
		return
	
	for rumor_template in rumors:
		var context = effects.duplicate()
		
		# Replace placeholders in rumor text
		var rumor_text = rumor_template
		for key in context:
			rumor_text = rumor_text.replace("{" + key + "}", str(context[key]))
		
		# Generate rumor
		rumor_system.generate_rumor("world_event", {
			"text": rumor_text,
			"context": context
		})

func _add_event_journal_entries(entries: Array[String], effects: Dictionary):
	## Add journal entries from event
	if not atmosphere_manager or not atmosphere_manager.journal_system:
		return
	
	for entry_template in entries:
		var player_name = game_manager.player.name if game_manager and game_manager.player else "Farmer"
		
		var entry_text = entry_template
		for key in effects:
			entry_text = entry_text.replace("{" + key + "}", str(effects[key]))
		
		atmosphere_manager.journal_system.add_entry("world_event", {
			"name": player_name,
			"text": entry_text,
			"year": GameManager.current_year,
			"generation": 1
		})

func _get_random_settlement() -> String:
	## Get random settlement ID
	var settlements = ["brassford", "ash_caravan", "rust_gate", "root_keepers"]
	return settlements[randi() % settlements.size()]

func _get_random_faction() -> String:
	## Get random faction ID
	var factions = ["machinists", "root_keepers", "rusted_brotherhood", "ash_caravans"]
	return factions[randi() % factions.size()]

func _adjust_settlement_prices(settlement_id: String, multiplier: float):
	## Adjust settlement prices
	var settlement = get_tree().get_first_node_in_group("settlement") as SettlementController
	if settlement:
		# Would modify base prices
		pass

func _reduce_settlement_stock(settlement_id: String, reduction: float):
	## Reduce settlement stock
	var settlement = get_tree().get_first_node_in_group("settlement") as SettlementController
	if settlement:
		# Would reduce current stock
		pass

func _spawn_refugees(settlement_id: String, count: int):
	## Spawn refugee NPCs
	# Would create temporary NPCs
	pass

func _void_faction_contracts(faction_id: String):
	## Void all contracts with faction
	var lineage = get_tree().get_first_node_in_group("lineage") as LineageSystem
	if lineage:
		# Would remove/void contracts
		pass

func _wipe_faction_reputation(faction_id: String):
	## Wipe faction reputation
	if game_manager and game_manager.player:
		game_manager.player.faction_relations.erase(faction_id)

func _transform_settlement_soil(settlement_id: String, soil_type: String):
	## Transform soil at settlement
	# Would affect farm tiles if settlement is player's farm
	pass

func process_year_tick():
	## Check for new events each year
	_check_events()

