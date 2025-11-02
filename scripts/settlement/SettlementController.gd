extends Control
class_name SettlementController

## Handles settlement interactions, trading, and services

signal trade_completed(item_id: String, quantity: int, price: int)
signal settlement_closed()

var settlement_data: Dictionary = {}
var player: Player
var world_controller: WorldController

# Trading state
var current_stock: Dictionary = {}  # Modified stock during visit
var player_reputation: Dictionary = {}  # Faction reputation

# UI references (would be connected to actual UI nodes)
@onready var inventory_list: ItemList = null
@onready var stock_list: ItemList = null
@onready var price_label: Label = null
@onready var attitude_label: Label = null

func _ready():
	player = GameManager.instance.player if GameManager.instance else null
	world_controller = get_tree().get_first_node_in_group("world") as WorldController
	
	if not player:
		push_error("Player not found!")

func open_settlement(settlement_id: String):
	## Open settlement interface
	_load_settlement(settlement_id)
	_update_ui()
	set_visible(true)

func _load_settlement(settlement_id: String):
	## Load settlement data from JSON
	var loader = DataLoader.new()
	var settlements = loader.load_json_file("res://data/world/settlements.json")
	
	for settlement in settlements:
		if settlement.get("id") == settlement_id:
			settlement_data = settlement.duplicate()
			break
	
	if settlement_data.is_empty():
		push_error("Settlement not found: " + settlement_id)
		return
	
	# Initialize stock (copy from settlement data)
	var stock_items = settlement_data.get("stock", [])
	current_stock = {}
	for item in stock_items:
		current_stock[item] = randf_range(5, 20)  # Random initial stock
	
	# Load player reputation
	_load_player_reputation()

func _load_player_reputation():
	## Load player faction reputation
	if player:
		player_reputation = player.faction_relations.duplicate()
	else:
		player_reputation = {}

func _update_ui():
	## Update settlement UI
	if settlement_data.is_empty():
		return
	
	# Update stock list
	if stock_list:
		stock_list.clear()
		for item_id in current_stock:
			var quantity = int(current_stock[item_id])
			if quantity > 0:
				var price = get_price(item_id)
				stock_list.add_item(item_id + " x" + str(quantity) + " (" + str(price) + " each)")
	
	# Update attitude display
	if attitude_label:
		var factions = settlement_data.get("factions", [])
		var attitude_text = "Faction Attitudes:\n"
		for faction in factions:
			var base_attitude = settlement_data.get("attitude", {}).get(faction, 0)
			var player_rep = player_reputation.get(faction, 0)
			var total_attitude = base_attitude + player_rep
			attitude_text += faction + ": " + str(total_attitude) + "\n"
		attitude_label.text = attitude_text
	
	# Update player inventory list
	if inventory_list and player:
		inventory_list.clear()
		var inventory = player.get_inventory()
		for item in inventory:
			var quantity = inventory[item]
			inventory_list.add_item(item + " x" + str(quantity))

func get_price(item_id: String) -> int:
	## Get price for item based on faction reputation and base price
	if not current_stock.has(item_id):
		return 0
	
	var base_prices = settlement_data.get("base_prices", {})
	var base_price = base_prices.get(item_id, 10)
	
	# Adjust price based on faction attitude
	var factions = settlement_data.get("factions", [])
	var total_attitude = 0
	for faction in factions:
		var base_attitude = settlement_data.get("attitude", {}).get(faction, 0)
		var player_rep = player_reputation.get(faction, 0)
		total_attitude += base_attitude + player_rep
	
	# Price modifier: -2% per attitude point (positive = cheaper)
	var price_modifier = 1.0 - (total_attitude * 0.02)
	price_modifier = clamp(price_modifier, 0.5, 1.5)  # Cap at 50% to 150%
	
	return int(base_price * price_modifier)

func buy_item(item_id: String, quantity: int) -> bool:
	## Buy item from settlement
	if not current_stock.has(item_id):
		return false
	
	var available = int(current_stock[item_id])
	if available < quantity:
		return false
	
	var price = get_price(item_id)
	var total_cost = price * quantity
	
	# Check if player has enough (assuming currency is "coins" or items)
	if not player:
		return false
	
	var inventory = player.get_inventory()
	var coins = inventory.get("coins", 0)
	
	# Allow bartering with items too
	# For now, simplified: assume player has currency
	if coins < total_cost:
		# Check if player can barter
		var can_barter = _can_barter(total_cost)
		if not can_barter:
			push_warning("Not enough coins! Need " + str(total_cost))
			return false
		else:
			_barter_for_item(item_id, quantity, total_cost)
			return true
	
	# Complete purchase
	player.remove_item("coins", total_cost)
	player.add_item(item_id, quantity)
	current_stock[item_id] = available - quantity
	
	# Update UI
	_update_ui()
	
	trade_completed.emit(item_id, quantity, total_cost)
	
	# Add journal entry
	var atmosphere = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	if atmosphere and atmosphere.journal_system:
		atmosphere.journal_system.add_entry("trade", {
			"name": player.name,
			"action": "bought",
			"item": item_id,
			"quantity": str(quantity),
			"settlement": settlement_data.get("name", ""),
			"year": GameManager.current_year,
			"generation": 1
		})
	
	return true

func sell_item(item_id: String, quantity: int) -> bool:
	## Sell item to settlement
	if not player:
		return false
	
	var inventory = player.get_inventory()
	var available = inventory.get(item_id, 0)
	if available < quantity:
		return false
	
	# Get sell price (usually lower than buy price)
	var buy_price = get_price(item_id)
	var sell_price = int(buy_price * 0.6)  # 60% of buy price
	var total_reward = sell_price * quantity
	
	# Complete sale
	player.remove_item(item_id, quantity)
	player.add_item("coins", total_reward)
	
	# Update stock
	if current_stock.has(item_id):
		current_stock[item_id] = current_stock[item_id] + quantity
	else:
		current_stock[item_id] = quantity
	
	# Update UI
	_update_ui()
	
	trade_completed.emit(item_id, -quantity, total_reward)
	
	# Add journal entry
	var atmosphere = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	if atmosphere and atmosphere.journal_system:
		atmosphere.journal_system.add_entry("trade", {
			"name": player.name,
			"action": "sold",
			"item": item_id,
			"quantity": str(quantity),
			"settlement": settlement_data.get("name", ""),
			"year": GameManager.current_year,
			"generation": 1
		})
	
	# Update faction reputation (small positive for trading)
	var factions = settlement_data.get("factions", [])
	for faction in factions:
		if not player.faction_relations.has(faction):
			player.faction_relations[faction] = 0
		player.faction_relations[faction] += 1
	
	return true

func _can_barter(required_value: int) -> bool:
	## Check if player has items worth bartering
	if not player:
		return false
	
	# Simplified: check if player has valuable items
	var inventory = player.get_inventory()
	var valuable_items = ["gear_blueprint", "steam_crystal", "metal_scrap"]
	
	for item in valuable_items:
		var quantity = inventory.get(item, 0)
		if quantity > 0:
			return true
	
	return false

func _barter_for_item(item_id: String, quantity: int, required_value: int):
	## Barter using items instead of currency
	# Simplified bartering system
	var inventory = player.get_inventory()
	var barter_items = ["gear_blueprint", "steam_crystal", "metal_scrap"]
	
	var remaining_value = required_value
	for barter_item in barter_items:
		var available = inventory.get(barter_item, 0)
		if available > 0:
			# Estimate value (simplified)
			var item_value = 10  # Would come from goods.json
			var needed = int(ceil(remaining_value / float(item_value)))
			var to_use = min(needed, available)
			
			player.remove_item(barter_item, to_use)
			remaining_value -= to_use * item_value
			
			if remaining_value <= 0:
				break
	
	if remaining_value <= 0:
		player.add_item(item_id, quantity)
		var available = int(current_stock[item_id])
		current_stock[item_id] = available - quantity
		_update_ui()

func get_settlement_state() -> Dictionary:
	## Get current settlement state for saving
	return {
		"id": settlement_data.get("id", ""),
		"stock": current_stock.duplicate(),
		"visited": true
	}

func load_settlement_state(state: Dictionary):
	## Load settlement state from save
	if state.has("stock"):
		current_stock = state.get("stock", {}).duplicate()

func close_settlement():
	## Close settlement interface
	set_visible(false)
	settlement_closed.emit()

