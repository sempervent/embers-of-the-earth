extends Node
class_name TutorialDirector

## FTUE system with diegetic guidance via journals and UI nudges

signal tutorial_step_completed(step_id: String)
signal tutorial_completed()
signal highlight_requested(target_path: String, message: String)

enum TutorialStep {
	WELCOME,
	TILL_SOIL,
	PLANT_CROP,
	HARVEST_CROP,
	TRAVEL_TOWN,
	TRADE_ITEM,
	RETURN_FARM,
	COMPLETE
}

var current_step: TutorialStep = TutorialStep.WELCOME
var completed_steps: Array[TutorialStep] = []
var is_active: bool = false
var skipped: bool = false

var player: Player
var farm_grid: FarmGrid
var world_controller: WorldController
var atmosphere_manager: AtmosphereManager

# Step messages (diegetic, themed)
var step_messages: Dictionary = {
	TutorialStep.WELCOME: {
		"title": "The Farm Awaits",
		"message": "Welcome, {name}. The soil remembers nothing yet. It is time to begin.",
		"journal_hint": "First entry written in your journal. Read it well."
	},
	TutorialStep.TILL_SOIL: {
		"title": "Prepare the Earth",
		"message": "Stand on any tile and press [E] to till the soil. The earth must be turned before seeds can take root.",
		"journal_hint": "The journal notes: 'Tilling breaks the crust. Only then can life take hold.'"
	},
	TutorialStep.PLANT_CROP: {
		"title": "Sow the First Seed",
		"message": "On tilled soil, press [E] again. Plant Ironwheat—it grows strong in these lands.",
		"journal_hint": "'The first seed carries hope. Ironwheat, the foundation of survival.'"
	},
	TutorialStep.HARVEST_CROP: {
		"title": "Reap What You Sow",
		"message": "Wait for crops to mature, then press [E] on them. Your harvest will fill your inventory.",
		"journal_hint": "'Harvest time. The cycle completes. The soil remembers.'"
	},
	TutorialStep.TRAVEL_TOWN: {
		"title": "Journey to Brassford",
		"message": "Visit a settlement to trade. Open the travel menu with [T]. Journey to Brassford—it lies east of here.",
		"journal_hint": "'The road calls. Settlements offer trade, alliances, and answers.'"
	},
	TutorialStep.TRADE_ITEM: {
		"title": "Exchange and Alliance",
		"message": "At the settlement, trade your harvest. Connections here can change your bloodline's fate.",
		"journal_hint": "'Commerce breeds relationships. Relationships forge futures.'"
	},
	TutorialStep.RETURN_FARM: {
		"title": "Home Again",
		"message": "Return to your farm. Your work continues. The earth waits.",
		"journal_hint": "'Home. The farm endures. The cycle begins anew.'"
	}
}

func _ready():
	player = GameManager.instance.player if GameManager.instance else null
	farm_grid = GameManager.instance.farm_grid if GameManager.instance else null
	world_controller = get_tree().get_first_node_in_group("world") as WorldController
	atmosphere_manager = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	
	# Check if tutorial should start
	var settings = get_tree().get_first_node_in_group("settings") as Settings
	if settings:
		var tutorial_completed = settings.get_setting("tutorial", "completed", false)
		var skip_tutorial = settings.get_setting("tutorial", "skip", false)
		
		if skip_tutorial:
			skipped = true
			is_active = false
			return
		
		if tutorial_completed:
			is_active = false
			return
	
	# Start tutorial
	start_tutorial()

func start_tutorial():
	## Begin the tutorial sequence
	is_active = true
	skipped = false
	current_step = TutorialStep.WELCOME
	
	# Write welcome journal entry
	if atmosphere_manager and atmosphere_manager.journal_system:
		var player_name = player.name if player else "Farmer"
		atmosphere_manager.journal_system.add_entry("tutorial_welcome", {
			"name": player_name,
			"year": GameManager.current_year,
			"generation": 1,
			"text": step_messages[TutorialStep.WELCOME].get("journal_hint", "")
		})
	
	_present_step(current_step)

func skip_tutorial():
	## Skip the tutorial
	skipped = true
	is_active = false
	current_step = TutorialStep.COMPLETE
	
	var settings = get_tree().get_first_node_in_group("settings") as Settings
	if settings:
		settings.set_setting("tutorial", "skip", true)
	
	# Close any tutorial UI
	_close_tutorial_ui()

func _present_step(step: TutorialStep):
	## Present a tutorial step
	if step == TutorialStep.COMPLETE:
		_complete_tutorial()
		return
	
	var message_data = step_messages.get(step, {})
	if message_data.is_empty():
		return
	
	var message = message_data.get("message", "")
	var title = message_data.get("title", "")
	
	# Replace placeholders
	if player:
		message = message.replace("{name}", player.name)
	
	# Show tutorial UI
	_show_tutorial_ui(title, message, step)
	
	# Highlight relevant UI elements
	_highlight_for_step(step)

func _highlight_for_step(step: TutorialStep):
	## Highlight UI elements or world objects for the current step
	match step:
		TutorialStep.TILL_SOIL:
			highlight_requested.emit("FarmGrid", "Stand on a tile and press [E]")
		TutorialStep.PLANT_CROP:
			highlight_requested.emit("FarmGrid", "Press [E] on tilled soil")
		TutorialStep.HARVEST_CROP:
			highlight_requested.emit("FarmGrid", "Press [E] on mature crops")
		TutorialStep.TRAVEL_TOWN:
			highlight_requested.emit("GameUI/TravelButton", "Press [T] to open travel menu")
		TutorialStep.TRADE_ITEM:
			highlight_requested.emit("SettlementController", "Select an item to trade")
		_:
			pass

func _show_tutorial_ui(title: String, message: String, step: TutorialStep):
	## Show tutorial overlay UI
	var tutorial_ui = get_tree().get_first_node_in_group("tutorial_ui") as TutorialOverlay
	if tutorial_ui:
		tutorial_ui.show_step(title, message, step)

func _close_tutorial_ui():
	## Close tutorial overlay
	var tutorial_ui = get_tree().get_first_node_in_group("tutorial_ui") as TutorialOverlay
	if tutorial_ui:
		tutorial_ui.hide()

# Hook into gameplay events
func on_tile_tilled():
	## Called when player tills soil
	if not is_active or skipped:
		return
	
	if current_step == TutorialStep.TILL_SOIL:
		_complete_step(TutorialStep.TILL_SOIL)
		current_step = TutorialStep.PLANT_CROP
		_present_step(current_step)

func on_crop_planted():
	## Called when player plants crop
	if not is_active or skipped:
		return
	
	if current_step == TutorialStep.PLANT_CROP:
		_complete_step(TutorialStep.PLANT_CROP)
		current_step = TutorialStep.HARVEST_CROP
		_present_step(current_step)

func on_crop_harvested():
	## Called when player harvests crop
	if not is_active or skipped:
		return
	
	if current_step == TutorialStep.HARVEST_CROP:
		_complete_step(TutorialStep.HARVEST_CROP)
		current_step = TutorialStep.TRAVEL_TOWN
		_present_step(current_step)

func on_travel_started(destination: String):
	## Called when player starts travel
	if not is_active or skipped:
		return
	
	if current_step == TutorialStep.TRAVEL_TOWN and destination == "brassford":
		_complete_step(TutorialStep.TRAVEL_TOWN)
		current_step = TutorialStep.TRADE_ITEM
		_present_step(current_step)

func on_trade_completed():
	## Called when player completes a trade
	if not is_active or skipped:
		return
	
	if current_step == TutorialStep.TRADE_ITEM:
		_complete_step(TutorialStep.TRADE_ITEM)
		current_step = TutorialStep.RETURN_FARM
		_present_step(current_step)

func on_returned_home():
	## Called when player returns to farm
	if not is_active or skipped:
		return
	
	if current_step == TutorialStep.RETURN_FARM:
		_complete_step(TutorialStep.RETURN_FARM)
		current_step = TutorialStep.COMPLETE
		_present_step(current_step)

func _complete_step(step: TutorialStep):
	## Mark a step as complete
	if not completed_steps.has(step):
		completed_steps.append(step)
	
	# Add journal entry
	if atmosphere_manager and atmosphere_manager.journal_system:
		var message_data = step_messages.get(step, {})
		var journal_hint = message_data.get("journal_hint", "")
		
		if not journal_hint.is_empty():
			atmosphere_manager.journal_system.add_entry("tutorial_step", {
				"name": player.name if player else "Farmer",
				"step": TutorialStep.keys()[step],
				"text": journal_hint,
				"year": GameManager.current_year,
				"generation": 1
			})
	
	tutorial_step_completed.emit(TutorialStep.keys()[step])

func _complete_tutorial():
	## Complete the tutorial
	is_active = false
	current_step = TutorialStep.COMPLETE
	
	# Save completion
	var settings = get_tree().get_first_node_in_group("settings") as Settings
	if settings:
		settings.set_setting("tutorial", "completed", true)
	
	# Final journal entry
	if atmosphere_manager and atmosphere_manager.journal_system:
		atmosphere_manager.journal_system.add_entry("tutorial_complete", {
			"name": player.name if player else "Farmer",
			"text": "The path ahead is yours. Tend the earth. Build your bloodline. The machine-god watches.",
			"year": GameManager.current_year,
			"generation": 1
		})
	
	tutorial_completed.emit()
	_close_tutorial_ui()

func get_tutorial_progress() -> float:
	## Get tutorial completion percentage
	if skipped:
		return 1.0
	
	var total_steps = TutorialStep.COMPLETE
	return float(completed_steps.size()) / float(total_steps)

func is_tutorial_active() -> bool:
	return is_active and not skipped

