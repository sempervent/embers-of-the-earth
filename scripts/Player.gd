extends Node
class_name Player

const DataLoader = preload("res://scripts/DataLoader.gd")

## Represents the player character with aging, traits, and bloodline

signal player_aged(new_age: int)
signal player_died(successor: Dictionary)

@export var character_name: String = "Elias Coalroot"  # Renamed to avoid conflict with Node.name
@export var age: int = 43
@export var traits: Array[String] = ["stubborn", "mechanically_gifted"]
@export var injuries: Array[String] = []
@export var children: Array[Dictionary] = []

var stats: Dictionary = {
	"strength": 10,
	"farming": 10,
	"crafting": 10,
	"diplomacy": 10,
	"resilience": 10,
	"travel": 5
}

var inventory: Dictionary = {}
var faction_relations: Dictionary = {}

func _ready():
	name = character_name  # Set Node.name for consistency
	_load_traits()

func _load_traits():
	## Load trait effects on stats
	var all_traits = DataLoader.load_json_file("res://data/traits.json")
	
	for trait_name in traits:
		for trait_data in all_traits:
			if trait_data.get("name") == trait_name:
				var modifiers = trait_data.get("stat_modifiers", {})
				for stat in modifiers:
					stats[stat] = stats.get(stat, 0) + modifiers[stat]

func age_up() -> bool:
	## Ages the player by one year. Returns true if player died.
	age += 1
	
	# Apply aging effects
	stats["strength"] = max(5, stats.get("strength", 10) - 0.5)
	stats["resilience"] = max(5, stats.get("resilience", 10) - 0.3)
	
	player_aged.emit(age)
	
	# Check for death (increasing probability with age)
	var death_chance = _calculate_death_chance()
	if randf() < death_chance:
		_die()
		return true
	
	return false

func _calculate_death_chance() -> float:
	## Calculates probability of death this year
	var base_chance = 0.01  # 1% at age 43
	var age_factor = (age - 43) * 0.02  # +2% per year over 43
	var injury_penalty = injuries.size() * 0.05  # +5% per injury
	
	return min(0.95, base_chance + age_factor + injury_penalty)

func _die():
	## Handles player death and succession
	if children.is_empty():
		# Game over - no successor
		push_error("Player died with no children!")
		return
	
	# Select a random child as successor (could be improved with choice/UI)
	var successor = children[randi() % children.size()]
	
	player_died.emit(successor)
	
	# Transfer control to successor
	_transfer_to_successor(successor)

func _transfer_to_successor(successor: Dictionary):
	## Transfers player control to a child
	character_name = successor.get("name", "Unknown Successor")
	name = character_name  # Set Node.name for consistency
	age = successor.get("age", 18)
	traits = successor.get("traits", []).duplicate()
	injuries = successor.get("injuries", []).duplicate()
	# Keep inventory and relations
	# Children list is preserved for next generation
	_load_traits()

func add_child_to_bloodline(child_data: Dictionary):
	## Adds a child to the bloodline (renamed to avoid conflict with Node.add_child)
	children.append(child_data)

func get_bloodline_children() -> Array[Dictionary]:
	## Returns children array (renamed to avoid conflict with Node.get_children)
	return children

func add_item(item_name: String, quantity: int = 1):
	## Adds an item to inventory
	inventory[item_name] = inventory.get(item_name, 0) + quantity

func remove_item(item_name: String, quantity: int = 1) -> bool:
	## Removes an item from inventory. Returns true if successful.
	if inventory.get(item_name, 0) < quantity:
		return false
	
	inventory[item_name] = inventory.get(item_name, 0) - quantity
	if inventory[item_name] <= 0:
		inventory.erase(item_name)
	
	return true

func has_item(item_name: String, quantity: int = 1) -> bool:
	## Checks if player has enough of an item
	return inventory.get(item_name, 0) >= quantity

func get_inventory() -> Dictionary:
	return inventory.duplicate()

func add_injury(injury_name: String):
	## Adds an injury (travel hazards, combat, etc.)
	if not injuries.has(injury_name):
		injuries.append(injury_name)
		stats["resilience"] = max(1, stats.get("resilience", 10) - 2)

func get_player_data() -> Dictionary:
	## Returns player data for saving
	return {
		"name": character_name,
		"age": age,
		"traits": traits.duplicate(),
		"injuries": injuries.duplicate(),
		"children": children.duplicate(true),
		"stats": stats.duplicate(),
		"inventory": inventory.duplicate(),
		"faction_relations": faction_relations.duplicate()
	}

func load_player_data(data: Dictionary):
	## Loads player data from a dictionary
	character_name = data.get("name", "Elias Coalroot")
	name = character_name  # Set Node.name for consistency
	age = data.get("age", 43)
	traits = data.get("traits", ["stubborn", "mechanically_gifted"]).duplicate()
	injuries = data.get("injuries", []).duplicate()
	children = data.get("children", []).duplicate(true)
	stats = data.get("stats", {
		"strength": 10,
		"farming": 10,
		"crafting": 10,
		"diplomacy": 10,
		"resilience": 10,
		"travel": 5
	}).duplicate()
	inventory = data.get("inventory", {}).duplicate()
	faction_relations = data.get("faction_relations", {}).duplicate()
	
	_load_traits()

