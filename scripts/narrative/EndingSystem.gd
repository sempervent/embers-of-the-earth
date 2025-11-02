extends Node
class_name EndingSystem

## Manages endings, epilogues, and legacy reflection

signal ending_triggered(ending_type: String, ending_data: Dictionary)
signal epilogue_ready(epilogue_data: Dictionary)

var ending_definitions: Dictionary = {}
var legacy_data: Dictionary = {}

var entropy_system: EntropySystem
var lineage_system: LineageSystem
var atmosphere_manager: AtmosphereManager
var npc_system: NPCSystem
var rumor_system: RumorSystem

func _ready():
	_load_endings()
	entropy_system = get_tree().get_first_node_in_group("entropy") as EntropySystem
	lineage_system = get_tree().get_first_node_in_group("lineage") as LineageSystem
	atmosphere_manager = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	npc_system = get_tree().get_first_node_in_group("npc_system") as NPCSystem
	rumor_system = get_tree().get_first_node_in_group("rumor_system") as RumorSystem
	
	add_to_group("endings")

func _load_endings():
	## Load ending definitions
	ending_definitions = {
		"order": {
			"name": "The Machine-God Awakens",
			"description": "Order triumphs. The machine beneath stirs. Iron consumes all.",
			"monologue_templates": [
				"After {generations} generations, the machine-god has awakened. Your bloodline chose iron over life.",
				"The great machine beneath the earth stirs. All soil turns to metal. All life becomes machine.",
				"Order has triumphed. Your family's legacy is steel and steam. The wild is forgotten."
			],
			"epilogue_scenes": ["machine_awakening", "iron_consumption", "steel_world"]
		},
		"wild": {
			"name": "Nature's Triumph",
			"description": "The wild consumes all. Nature reigns supreme.",
			"monologue_templates": [
				"After {generations} generations, nature has reclaimed the land. Your bloodline chose life over machine.",
				"The wild spreads. Machines rust. Pure soil grows where steel once stood.",
				"Nature triumphs. Your family's legacy is green and growing. The machine-god sleeps forever."
			],
			"epilogue_scenes": ["wild_reclamation", "nature_triumph", "green_world"]
		},
		"extinction": {
			"name": "The Bloodline Ends",
			"description": "Your family line has died out. No heirs remain.",
			"monologue_templates": [
				"The last of the {family_name} is gone. The bloodline ends. The earth forgets.",
				"No heirs. No future. The legacy dies with you.",
				"The farm lies abandoned. The soil remembers nothing now."
			],
			"epilogue_scenes": ["abandoned_farm", "forgotten_legacy", "empty_world"]
		},
		"wandering_npc": {
			"name": "The Wandering Path",
			"description": "You abandon the farm and become a wandering NPC.",
			"monologue_templates": [
				"You left the farm. The road calls. Your bloodline continues elsewhere.",
				"The farm is sold. You wander. Stories spread of the {family_name} who left the land.",
				"Rootless. Free. Your legacy is in the stories others tell."
			],
			"epilogue_scenes": ["wandering_path", "road_legacy", "nomad_end"]
		}
	}

func trigger_ending(ending_type: String):
	## Trigger an ending
	if not ending_definitions.has(ending_type):
		push_error("Ending not found: " + ending_type)
		return
	
	var ending_data = ending_definitions[ending_type].duplicate()
	
	# Generate monologue
	var monologue = _generate_monologue(ending_type, ending_data)
	ending_data["monologue"] = monologue
	
	# Generate epilogue
	var epilogue = _generate_epilogue(ending_type)
	
	ending_triggered.emit(ending_type, ending_data)
	epilogue_ready.emit(epilogue)
	
	# Show ending screen
	_show_ending_screen(ending_data, epilogue)

func _generate_monologue(ending_type: String, ending_data: Dictionary) -> String:
	## Generate ending monologue based on generations of choices
	var templates = ending_data.get("monologue_templates", [])
	if templates.is_empty():
		return "The story ends."
	
	var template = templates[randi() % templates.size()]
	
	# Replace placeholders
	var game_manager = GameManager.instance
	var family_identity = get_tree().get_first_node_in_group("family_identity") as FamilyIdentitySystem
	
	var generation_count = 1
	if lineage_system:
		var lineage_data = lineage_system.get_lineage_data()
		generation_count = lineage_data.get("generations", []).size() + 1
	
	var family_name = family_identity.family_name if family_identity else "Coalroot"
	
	template = template.replace("{generations}", str(generation_count))
	template = template.replace("{family_name}", family_name)
	
	# Add generation-specific details
	var years_active = GameManager.current_year
	template += "\n\nAfter " + str(years_active) + " years, the legacy is complete."
	
	return template

func _generate_epilogue(ending_type: String) -> Dictionary:
	## Generate epilogue with family tree, graves, stolen heirlooms
	var epilogue: Dictionary = {
		"ending_type": ending_type,
		"family_tree": _generate_family_tree_summary(),
		"final_rumors": _generate_final_rumors(),
		"missing_heirlooms": _get_missing_heirlooms(),
		"npc_memories": _get_npc_final_memories(),
		"final_statistics": _generate_final_statistics()
	}
	
	return epilogue

func _generate_family_tree_summary() -> Dictionary:
	## Generate family tree summary for epilogue
	if not lineage_system:
		return {}
	
	var lineage_data = lineage_system.get_lineage_data()
	var generations = lineage_data.get("generations", [])
	
	var tree_summary = {
		"total_generations": generations.size(),
		"generations": []
	}
	
	for gen_data in generations:
		var gen_num = gen_data.get("generation", 1)
		var successor = gen_data.get("successor", {})
		var year = gen_data.get("year", 1)
		
		tree_summary["generations"].append({
			"generation": gen_num,
			"name": successor.get("name", "Unknown"),
			"age": successor.get("age", 0),
			"year": year
		})
	
	return tree_summary

func _generate_final_rumors() -> Array[String]:
	## Generate final rumors about the bloodline
	if not rumor_system:
		return []
	
	var final_rumors: Array[String] = []
	var active_rumors = rumor_system.get_active_rumors()
	
	for rumor in active_rumors:
		final_rumors.append(rumor.get("text", ""))
	
	# Generate legacy rumors
	var family_identity = get_tree().get_first_node_in_group("family_identity") as FamilyIdentitySystem
	var family_name = family_identity.family_name if family_identity else "Coalroot"
	
	final_rumors.append("The " + family_name + " bloodline is remembered. Their legacy echoes.")
	final_rumors.append("Some say the " + family_name + " family still tends the old farm.")
	final_rumors.append("The stories of the " + family_name + " will fade, but never disappear.")
	
	return final_rumors

func _get_missing_heirlooms() -> Array[String]:
	## Get list of lost heirlooms
	var heirloom_system = get_tree().get_first_node_in_group("heirlooms") as HeirloomSystem
	if not heirloom_system:
		return []
	
	var lost = heirloom_system.get_lost_heirlooms()
	var lost_names: Array[String] = []
	
	var loader = DataLoader.new()
	var all_heirlooms = loader.load_json_file("res://data/heirlooms/heirlooms.json")
	
	for heirloom_id in lost:
		for heirloom in all_heirlooms:
			if heirloom.get("id") == heirloom_id:
				lost_names.append(heirloom.get("name", heirloom_id))
				break
	
	return lost_names

func _get_npc_final_memories() -> Dictionary:
	## Get final NPC memories of the bloodline
	if not npc_system:
		return {}
	
	var memories: Dictionary = {}
	
	for npc_id in npc_system.npcs:
		var npc_memories = npc_system.get_npc_memories(npc_id)
		var opinion = npc_system.get_npc_opinion(npc_id)
		
		memories[npc_id] = {
			"opinion": opinion,
			"memory_count": npc_memories.size(),
			"final_quote": npc_system.get_npc_quote(npc_id, "final")
		}
	
	return memories

func _generate_final_statistics() -> Dictionary:
	## Generate final game statistics
	var stats: Dictionary = {
		"years_played": GameManager.current_year,
		"days_played": GameManager.current_day,
		"generations": 1,
		"crops_harvested": 0,
		"trades_completed": 0,
		"marriages": 0,
		"buildings_placed": 0,
		"travel_distance": 0.0,
		"final_order_entropy": 0.0,
		"final_wild_entropy": 0.0
	}
	
	# Get actual statistics from systems
	if entropy_system:
		stats["final_order_entropy"] = entropy_system.order_level
		stats["final_wild_entropy"] = entropy_system.wild_level
	
	if lineage_system:
		var lineage_data = lineage_system.get_lineage_data()
		stats["generations"] = lineage_data.get("generations", []).size() + 1
		stats["marriages"] = lineage_system.completed_contracts.size()
	
	var rpg_stats = get_tree().get_first_node_in_group("rpg_stats") as RPGStatsSystem
	if rpg_stats:
		var progression = rpg_stats.get_progression_data()
		stats["crops_harvested"] = progression.get("harvest_count", 0)
		stats["trades_completed"] = progression.get("trade_count", 0)
		stats["travel_distance"] = progression.get("travel_distance", 0.0)
	
	var production = get_tree().get_first_node_in_group("production") as ProductionSystem
	if production:
		stats["buildings_placed"] = production.buildings.size()
	
	return stats

func _show_ending_screen(ending_data: Dictionary, epilogue: Dictionary):
	## Show ending screen
	# Would transition to ending scene
	print("=== ENDING ===")
	print(ending_data.get("name", ""))
	print(ending_data.get("monologue", ""))
	print("\n=== EPILOGUE ===")
	print(JSON.stringify(epilogue, "\t"))

func generate_ending_poem(ending_type: String) -> String:
	## Generate procedurally generated ending poem
	var family_identity = get_tree().get_first_node_in_group("family_identity") as FamilyIdentitySystem
	var family_name = family_identity.family_name if family_identity else "Coalroot"
	
	var poems = {
		"order": [
			"The machine stirs.\nIron consumes all.\nYour bloodline chose steel.\nThe wild sleeps forever.",
			"Gears turn.\nSoil becomes metal.\nYour legacy is order.\nNature is forgotten."
		],
		"wild": [
			"Green spreads.\nMachines rust.\nYour bloodline chose life.\nThe machine-god sleeps.",
			"Roots reclaim.\nSteel crumbles.\nYour legacy is nature.\nOrder is broken."
		],
		"extinction": [
			"The last farmer dies.\nThe soil forgets.\nYour bloodline ends.\nThe earth moves on.",
			"No heirs remain.\nThe farm lies empty.\nYour legacy fades.\nThe world continues."
		]
	}
	
	var poem_list = poems.get(ending_type, [])
	if poem_list.is_empty():
		return "The story ends."
	
	var poem = poem_list[randi() % poem_list.size()]
	poem = poem.replace("{family_name}", family_name)
	
	return poem

