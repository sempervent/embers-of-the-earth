extends Node
class_name RumorSystem

## Generates, propagates, and delivers rumors throughout the world

signal rumor_generated(rumor_id: String, rumor_text: String)
signal rumor_delivered(delivery_method: String, rumor_text: String)

var active_rumors: Array[Dictionary] = []
var rumor_history: Array[Dictionary] = []

var npc_system: NPCSystem
var atmosphere_manager: AtmosphereManager
var game_manager: GameManager

const RUMOR_LIFETIME_DAYS = 60  # Rumors fade after 60 days
const RUMOR_PROPAGATION_CHANCE = 0.3  # Chance to spread per day

func _ready():
	npc_system = get_tree().get_first_node_in_group("npc_system") as NPCSystem
	atmosphere_manager = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	game_manager = GameManager.instance
	
	add_to_group("rumor_system")

func generate_rumor(rumor_type: String, context: Dictionary) -> Dictionary:
	## Generate a new rumor
	var rumor_id = rumor_type + "_" + str(Time.get_unix_time_from_system())
	
	var rumor_text = _generate_rumor_text(rumor_type, context)
	
	var rumor: Dictionary = {
		"id": rumor_id,
		"type": rumor_type,
		"text": rumor_text,
		"context": context,
		"birth_day": GameManager.current_day,
		"birth_year": GameManager.current_year,
		"propagation_count": 0,
		"delivered_methods": []
	}
	
	active_rumors.append(rumor)
	rumor_history.append(rumor.duplicate())
	
	rumor_generated.emit(rumor_id, rumor_text)
	
	# Deliver rumor immediately via random method
	_deliver_rumor(rumor)
	
	return rumor

func _generate_rumor_text(rumor_type: String, context: Dictionary) -> String:
	## Generate rumor text from templates
	var templates = _get_rumor_templates(rumor_type)
	if templates.is_empty():
		return "Rumors spread. Their meaning is unclear."
	
	var template = templates[randi() % templates.size()]
	
	# Replace placeholders
	var rumor_text = template
	for key in context:
		rumor_text = rumor_text.replace("{" + key + "}", str(context[key]))
	
	return rumor_text

func _get_rumor_templates(rumor_type: String) -> Array[String]:
	## Get rumor templates for type
	match rumor_type:
		"bandit_attack":
			return [
				"Bandits attacked the {player_name} caravan. They say nothing was spared.",
				"Heard the Coalroots were ambushed. Some say they deserved it.",
				"Word on the road: bandits got the Coalroot trade goods."
			]
		"contract_broken":
			return [
				"The {faction} say the Coalroots broke a contract. Trust is gone.",
				"Rumors say your bloodline dishonored a contract with {faction}.",
				"The {faction} remember. They always remember broken promises."
			]
		"heirloom_lost":
			return [
				"The Coalroot heirloom seeds are gone. Stolen or lost—same difference.",
				"Heard they lost the heirloom. Family history reduced to rumor.",
				"The heirloom seeds disappeared. Some say bandits. Others say worse."
			]
		"npc_death":
			return [
				"{npc_name} is dead. The {settlement} mourns.",
				"Word from {settlement}: {npc_name} passed. Age takes everyone eventually.",
				"Heard {npc_name} died. Another memory gone."
			]
		"settlement_burned":
			return [
				"{settlement} burned. They say it was the machine-god's anger.",
				"Fire consumed {settlement}. Nothing left but ash.",
				"Rumors speak of a great fire at {settlement}. Survivors tell terrible stories."
			]
		"marriage_forced":
			return [
				"The Coalroots traded a daughter to {faction}. Nothing good grows from iron wombs.",
				"Rumors say the Coalroot marriage was forced. Desperation, not alliance.",
				"They say your bloodline sold its future to {faction}. The price was too high."
			]
		_:
			return ["Rumors spread. Their source is unknown."]

func _deliver_rumor(rumor: Dictionary):
	## Deliver rumor via random method
	var delivery_methods = ["journal", "tavern", "market", "letter", "overheard"]
	var method = delivery_methods[randi() % delivery_methods.size()]
	
	if rumor["delivered_methods"].has(method):
		# Try another method
		method = delivery_methods[randi() % delivery_methods.size()]
	
	rumor["delivered_methods"].append(method)
	_deliver_via_method(rumor, method)

func _deliver_via_method(rumor: Dictionary, method: String):
	## Deliver rumor via specific method
	match method:
		"journal":
			_deliver_via_journal(rumor)
		"tavern":
			_deliver_via_tavern(rumor)
		"market":
			_deliver_via_market(rumor)
		"letter":
			_deliver_via_letter(rumor)
		"overheard":
			_deliver_via_overheard(rumor)

func _deliver_via_journal(rumor: Dictionary):
	## Deliver rumor as journal entry
	if atmosphere_manager and atmosphere_manager.journal_system:
		var player_name = game_manager.player.name if game_manager and game_manager.player else "Farmer"
		atmosphere_manager.journal_system.add_entry("rumor", {
			"name": player_name,
			"text": "[Rumor] " + rumor["text"],
			"year": GameManager.current_year,
			"generation": 1
		})
	
	rumor_delivered.emit("journal", rumor["text"])

func _deliver_via_tavern(rumor: Dictionary):
	## Deliver rumor in tavern dialogue
	# Would appear as NPC dialogue when player visits tavern
	var npc = _get_random_tavern_npc()
	if npc_system and npc:
		var npc_id = npc.get("id", "")
		var quote = npc_system.get_npc_quote(npc_id, "rumor")
		if quote.is_empty():
			quote = rumor["text"]
	
	rumor_delivered.emit("tavern", rumor["text"])

func _deliver_via_market(rumor: Dictionary):
	## Deliver rumor as market chatter
	# Would appear as ambient text in market UI
	rumor_delivered.emit("market", rumor["text"])

func _deliver_via_letter(rumor: Dictionary):
	## Deliver rumor via letter
	# Would create a letter item that player can read
	rumor_delivered.emit("letter", rumor["text"])

func _deliver_via_overheard(rumor: Dictionary):
	## Deliver rumor as overheard dialogue
	# Would appear as UI whisper/floating text
	rumor_delivered.emit("overheard", rumor["text"])

func _get_random_tavern_npc() -> Dictionary:
	## Get random NPC who might be in tavern
	if not npc_system:
		return {}
	
	var all_npcs = npc_system.npcs.values()
	if all_npcs.is_empty():
		return {}
	
	# Filter NPCs who visit taverns
	var tavern_npcs: Array[Dictionary] = []
	for npc in all_npcs:
		var schedule = npc.get("schedule", {})
		if schedule.has("evening") and schedule["evening"] == "tavern":
			tavern_npcs.append(npc)
	
	if tavern_npcs.is_empty():
		return all_npcs[randi() % all_npcs.size()]
	
	return tavern_npcs[randi() % tavern_npcs.size()]

func process_day():
	## Process rumor propagation and decay
	var current_day = GameManager.current_day
	var rumors_to_remove: Array[Dictionary] = []
	
	for rumor in active_rumors:
		var age_days = current_day - rumor["birth_day"]
		
		# Remove old rumors
		if age_days > RUMOR_LIFETIME_DAYS:
			rumors_to_remove.append(rumor)
			continue
		
		# Propagate rumor (spread to new settlements/NPCs)
		if randf() < RUMOR_PROPAGATION_CHANCE:
			_propagate_rumor(rumor)
	
	# Remove expired rumors
	for rumor in rumors_to_remove:
		active_rumors.erase(rumor)

func _propagate_rumor(rumor: Dictionary):
	## Propagate rumor to new locations/NPCs
	rumor["propagation_count"] = rumor.get("propagation_count", 0) + 1
	
	# Deliver to a new method if available
	var delivery_methods = ["journal", "tavern", "market", "letter", "overheard"]
	var undelivered = []
	
	for method in delivery_methods:
		if not rumor["delivered_methods"].has(method):
			undelivered.append(method)
	
	if not undelivered.is_empty():
		var method = undelivered[randi() % undelivered.size()]
		_deliver_via_method(rumor, method)

func get_active_rumors() -> Array[Dictionary]:
	## Get all active rumors
	return active_rumors.duplicate()

func get_rumor_history() -> Array[Dictionary]:
	## Get full rumor history
	return rumor_history.duplicate()

