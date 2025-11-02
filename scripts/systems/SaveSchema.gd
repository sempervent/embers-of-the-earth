extends RefCounted
class_name SaveSchema

## Versioned save schema for game state

const SCHEMA_VERSION = 2

static func serialize_game_state() -> Dictionary:
	## Serialize complete game state
	var game_manager = GameManager.instance
	if not game_manager:
		return {}
	
	var save_data = {
		"schema_version": SCHEMA_VERSION,
		"game_state": {
			"current_day": GameManager.current_day,
			"current_year": GameManager.current_year,
			"current_season": GameManager.current_season
		},
		"player_state": {},
		"farm_state": {},
		"world_state": {},
		"settlement_states": {},
		"faction_reputations": {},
		"lineage_state": {},
		"production_state": {},
		"entropy_state": {}
	}
	
	# Player state
	if game_manager.player:
		save_data["player_state"] = game_manager.player.get_player_data()
	
	# Farm state
	if game_manager.farm_grid:
		save_data["farm_state"] = game_manager.farm_grid.get_farm_data()
	
	# World state
	var world = game_manager.get_tree().get_first_node_in_group("world") as WorldController
	if world:
		save_data["world_state"] = {
			"current_region": world.current_region_id,
			"is_traveling": world.is_traveling
		}
	
	# Settlement states
	var settlement = game_manager.get_tree().get_first_node_in_group("settlement") as SettlementController
	if settlement:
		save_data["settlement_states"] = settlement.get_settlement_state()
	
	# Faction reputations (from player)
	if game_manager.player:
		save_data["faction_reputations"] = game_manager.player.faction_relations.duplicate()
	
	# Lineage state
	var lineage = game_manager.get_tree().get_first_node_in_group("lineage") as LineageSystem
	if lineage:
		save_data["lineage_state"] = {
			"active_contracts": lineage.get_active_contracts(),
			"completed_contracts": lineage.get_completed_contracts(),
			"lineage_tree": lineage.get_lineage_data()
		}
	
	# Production state
	var production = game_manager.get_tree().get_first_node_in_group("production") as ProductionSystem
	if production:
		save_data["production_state"] = production.get_production_data()
	
	# Entropy state
	var entropy = game_manager.get_tree().get_first_node_in_group("entropy") as EntropySystem
	if entropy:
		save_data["entropy_state"] = entropy.get_entropy_data()
	
	return save_data

static func deserialize_game_state(save_data: Dictionary) -> bool:
	## Deserialize and load game state
	if not save_data.has("schema_version"):
		push_error("Save file missing schema version")
		return false
	
	var version = save_data.get("schema_version", 0)
	
	# Migrate if needed
	if version < SCHEMA_VERSION:
		save_data = _migrate_save_data(save_data, version, SCHEMA_VERSION)
	
	var game_manager = GameManager.instance
	if not game_manager:
		return false
	
	# Load game state
	if save_data.has("game_state"):
		var state = save_data.get("game_state", {})
		GameManager.current_day = state.get("current_day", 1)
		GameManager.current_year = state.get("current_year", 1)
		GameManager.current_season = state.get("current_season", "spring")
	
	# Load player state
	if save_data.has("player_state") and game_manager.player:
		game_manager.player.load_player_data(save_data.get("player_state", {}))
	
	# Load farm state
	if save_data.has("farm_state") and game_manager.farm_grid:
		game_manager.farm_grid.load_farm_data(save_data.get("farm_state", {}))
	
	# Load world state
	var world = game_manager.get_tree().get_first_node_in_group("world") as WorldController
	if world and save_data.has("world_state"):
		var world_state = save_data.get("world_state", {})
		world.current_region_id = world_state.get("current_region", "home_farm")
		world.is_traveling = world_state.get("is_traveling", false)
	
	# Load settlement states
	var settlement = game_manager.get_tree().get_first_node_in_group("settlement") as SettlementController
	if settlement and save_data.has("settlement_states"):
		settlement.load_settlement_state(save_data.get("settlement_states", {}))
	
	# Load faction reputations
	if save_data.has("faction_reputations") and game_manager.player:
		game_manager.player.faction_relations = save_data.get("faction_reputations", {}).duplicate()
	
	# Load lineage state
	var lineage = game_manager.get_tree().get_first_node_in_group("lineage") as LineageSystem
	if lineage and save_data.has("lineage_state"):
		var lineage_state = save_data.get("lineage_state", {})
		lineage.active_contracts = lineage_state.get("active_contracts", [])
		lineage.completed_contracts = lineage_state.get("completed_contracts", [])
		lineage.lineage_tree = lineage_state.get("lineage_tree", {})
	
	# Load production state
	var production = game_manager.get_tree().get_first_node_in_group("production") as ProductionSystem
	if production and save_data.has("production_state"):
		production.load_production_data(save_data.get("production_state", {}))
	
	# Load entropy state
	var entropy = game_manager.get_tree().get_first_node_in_group("entropy") as EntropySystem
	if entropy and save_data.has("entropy_state"):
		entropy.load_entropy_data(save_data.get("entropy_state", {}))
	
	return true

static func _migrate_save_data(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
	## Migrate save data between schema versions
	var migrated = data.duplicate(true)
	
	# Migration from v1 to v2: add new systems
	if from_version < 2 and to_version >= 2:
		if not migrated.has("world_state"):
			migrated["world_state"] = {}
		if not migrated.has("settlement_states"):
			migrated["settlement_states"] = {}
		if not migrated.has("lineage_state"):
			migrated["lineage_state"] = {}
		if not migrated.has("production_state"):
			migrated["production_state"] = {}
		if not migrated.has("entropy_state"):
			migrated["entropy_state"] = {}
		
		migrated["schema_version"] = 2
	
	return migrated

