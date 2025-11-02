extends Node
class_name NPCSystem

## Manages NPCs, their personalities, schedules, and relationships with the player's bloodline

signal npc_met(npc_id: String)
signal npc_opinion_changed(npc_id: String, new_opinion: int)
signal npc_quote_spoken(npc_id: String, quote: String)

var npcs: Dictionary = {}  # npc_id -> NPCData
var npc_schedules: Dictionary = {}  # npc_id -> ScheduleData
var npc_opinions: Dictionary = {}  # npc_id -> opinion_value (-100 to 100)
var npc_memories: Dictionary = {}  # npc_id -> [memory_events]

var player_lineage: LineageSystem
var game_manager: GameManager

func _ready():
	_load_npcs()
	_initialize_opinions()
	_initialize_schedules()
	
	game_manager = GameManager.instance
	player_lineage = get_tree().get_first_node_in_group("lineage") as LineageSystem

func _load_npcs():
	## Load NPCs from JSON
	var loader = DataLoader.new()
	var npc_list = loader.load_json_file("res://data/npcs/npcs.json")
	
	for npc_data in npc_list:
		var npc_id = npc_data.get("id", "")
		if npc_id.is_empty():
			continue
		
		npcs[npc_id] = npc_data.duplicate()

func _initialize_opinions():
	## Initialize NPC opinions based on base values and lineage memory
	for npc_id in npcs:
		var npc = npcs[npc_id]
		var base_opinion = npc.get("personality", {}).get("opinion_base", 0)
		
		# Adjust based on lineage memory
		var memory_events = npc.get("memory_events", [])
		for event_id in memory_events:
			if _bloodline_has_memory(event_id):
				base_opinion -= 10  # Negative memory reduces opinion
		
		npc_opinions[npc_id] = base_opinion

func _initialize_schedules():
	## Initialize NPC daily schedules
	for npc_id in npcs:
		var npc = npcs[npc_id]
		var schedule = npc.get("schedule", {})
		npc_schedules[npc_id] = schedule.duplicate()

func get_npc(npc_id: String) -> Dictionary:
	## Get NPC data by ID
	return npcs.get(npc_id, {})

func get_npcs_at_settlement(settlement_id: String) -> Array[Dictionary]:
	## Get all NPCs at a settlement
	var settlement_npcs: Array[Dictionary] = []
	
	for npc_id in npcs:
		var npc = npcs[npc_id]
		if npc.get("settlement") == settlement_id:
			settlement_npcs.append(npc.duplicate())
	
	return settlement_npcs

func get_npc_location(npc_id: String, time_of_day: String) -> String:
	## Get NPC's location at a given time of day
	var schedule = npc_schedules.get(npc_id, {})
	return schedule.get(time_of_day, "unknown")

func get_npc_opinion(npc_id: String) -> int:
	## Get NPC's opinion of player (-100 to 100)
	return npc_opinions.get(npc_id, 0)

func change_opinion(npc_id: String, amount: int, reason: String = ""):
	## Change NPC's opinion of player
	if not npc_opinions.has(npc_id):
		return
	
	var old_opinion = npc_opinions[npc_id]
	npc_opinions[npc_id] = clamp(old_opinion + amount, -100, 100)
	
	if old_opinion != npc_opinions[npc_id]:
		npc_opinion_changed.emit(npc_id, npc_opinions[npc_id])
		
		# Log reason if provided
		if not reason.is_empty():
			_add_memory(npc_id, reason)

func get_npc_quote(npc_id: String, context: String = "neutral") -> String:
	## Get a quote from NPC based on opinion
	var npc = npcs.get(npc_id, {})
	if npc.is_empty():
		return ""
	
	var quotes = npc.get("quotes", {})
	var opinion = get_npc_opinion(npc_id)
	
	# Determine quote category
	var quote_category = "neutral"
	if opinion > 20:
		quote_category = "positive"
	elif opinion < -20:
		quote_category = "negative"
	
	# Try to use context if available, fall back to opinion-based
	var quote_list = quotes.get(context, quotes.get(quote_category, quotes.get("neutral", [])))
	
	if quote_list.is_empty():
		return ""
	
	# Select random quote
	var quote = quote_list[randi() % quote_list.size()]
	
	# Replace placeholders
	quote = _replace_quote_placeholders(quote, npc_id)
	
	npc_quote_spoken.emit(npc_id, quote)
	return quote

func _replace_quote_placeholders(quote: String, npc_id: String) -> String:
	## Replace placeholders in quotes
	# Would replace {player_name}, {faction}, etc.
	if game_manager and game_manager.player:
		quote = quote.replace("{player_name}", game_manager.player.name)
	
	return quote

func _bloodline_has_memory(event_id: String) -> bool:
	## Check if bloodline has a specific memory event
	if not player_lineage:
		return false
	
	# Would check lineage tree for memory events
	return false  # Simplified

func _add_memory(npc_id: String, memory: String):
	## Add a memory event to NPC's memory
	if not npc_memories.has(npc_id):
		npc_memories[npc_id] = []
	
	npc_memories[npc_id].append({
		"memory": memory,
		"year": GameManager.current_year,
		"day": GameManager.current_day
	})

func process_year_tick():
	## Process NPC aging and relationship changes
	for npc_id in npcs:
		var npc = npcs[npc_id]
		var age = npc.get("age", 0)
		
		# NPCs age
		npc["age"] = age + 1
		
		# Aging affects opinions (elders become more rigid)
		if age > 60:
			var current_opinion = get_npc_opinion(npc_id)
			# Opinions become more extreme with age
			if current_opinion > 0:
				npc_opinions[npc_id] = min(100, current_opinion + 1)
			elif current_opinion < 0:
				npc_opinions[npc_id] = max(-100, current_opinion - 1)
		
		# Check for NPC death (simplified)
		if age > 80 and randf() < 0.05:
			_handle_npc_death(npc_id)

func _handle_npc_death(npc_id: String):
	## Handle NPC death
	var npc = npcs[npc_id]
	var name = npc.get("name", "Unknown")
	
	# Remove NPC from active list
	# Would mark as deceased but keep in memory
	
	# Generate rumor about death
	var rumor_system = get_tree().get_first_node_in_group("rumor_system") as RumorSystem
	if rumor_system:
		rumor_system.generate_rumor("npc_death", {
			"npc_name": name,
			"settlement": npc.get("settlement", "")
		})

func meet_npc(npc_id: String):
	## Player meets NPC
	if not npc_opinions.has(npc_id):
		npc_opinions[npc_id] = 0
	
	npc_met.emit(npc_id)
	
	# Generate greeting quote
	var quote = get_npc_quote(npc_id, "greeting")
	return quote

func get_npc_memories(npc_id: String) -> Array[Dictionary]:
	## Get NPC's memories of the player's bloodline
	return npc_memories.get(npc_id, []).duplicate()

