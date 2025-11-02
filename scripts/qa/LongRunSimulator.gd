extends Node
class_name LongRunSimulator

## Simulates 100+ years across bloodlines to detect crashes and unwinnable states

signal simulation_started()
signal simulation_progress(year: int, generation: int)
signal simulation_completed(success: bool, crash_year: int)

var is_simulating: bool = false
var max_years: int = 100
var current_year: int = 1
var crash_detected: bool = false

var game_manager: GameManager

func _ready():
	game_manager = GameManager.instance
	add_to_group("qa_testing")

func run_long_simulation(years: int = 100):
	## Run long simulation to detect crashes
	is_simulating = true
	max_years = years
	current_year = 1
	crash_detected = false
	
	simulation_started.emit()
	
	# Run simulation year by year
	_run_simulation_loop()

func _run_simulation_loop():
	## Main simulation loop
	while current_year <= max_years and not crash_detected:
		# Advance year
		if game_manager:
			for day in 120:  # One year = 120 days
				game_manager.advance_day()
				
				# Check for crashes
				if _check_for_crashes():
					crash_detected = true
					break
			
			current_year += 1
			simulation_progress.emit(current_year, 1)
			
			# Check for unwinnable states
			if _check_unwinnable():
				crash_detected = true
				break
			
			# Small delay to prevent freezing
			await get_tree().create_timer(0.01).timeout
		else:
			crash_detected = true
			break
	
	_simulation_complete()

func _check_for_crashes() -> bool:
	## Check for crash conditions
	if not game_manager:
		return true
	
	if game_manager.player:
		# Check for invalid stats
		for stat in game_manager.player.stats:
			if game_manager.player.stats[stat] < 0:
				print("CRASH: Negative stat detected: " + stat)
				return true
		
		# Check for invalid inventory
		var inventory = game_manager.player.get_inventory()
		for item in inventory:
			if inventory[item] < 0:
				print("CRASH: Negative inventory: " + item)
				return true
	
	# Check for farm grid errors
	if game_manager.farm_grid:
		for tile in game_manager.farm_grid.tiles.values():
			if tile.crop_growth_stage < 0 or tile.crop_growth_stage > 10:
				print("CRASH: Invalid crop growth stage")
				return true
	
	return false

func _check_unwinnable() -> bool:
	## Check for unwinnable states
	if not game_manager or not game_manager.player:
		return false
	
	# Check if player is stuck (no food, no fuel, can't travel)
	var inventory = game_manager.player.get_inventory()
	var food = inventory.get("food", 0)
	var fuel = inventory.get("fuel", 0)
	
	# Check if farm has any crops
	var has_crops = false
	if game_manager.farm_grid:
		for tile in game_manager.farm_grid.tiles.values():
			if tile.current_crop != "":
				has_crops = true
				break
	
	# Unwinnable if: no food, no fuel, no crops, can't travel
	if food <= 0 and fuel <= 0 and not has_crops:
		# Check if player can still get resources
		var can_travel = false
		var world = get_tree().get_first_node_in_group("world") as WorldController
		if world:
			var destinations = world.get_available_destinations()
			can_travel = not destinations.is_empty()
		
		if not can_travel:
			print("UNWINNABLE: No food, no fuel, no crops, can't travel")
			return true
	
	return false

func _simulation_complete():
	## Complete simulation
	is_simulating = false
	
	var success = not crash_detected
	var crash_year = current_year if crash_detected else 0
	
	simulation_completed.emit(success, crash_year)
	
	print("=== Simulation Complete ===")
	print("Years simulated: " + str(current_year))
	print("Success: " + str(success))
	if crash_detected:
		print("Crash detected at year: " + str(crash_year))

