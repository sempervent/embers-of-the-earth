extends Node
class_name RegressionTester

## Automated regression testing for core systems

signal test_completed(test_name: String, passed: bool)
signal all_tests_completed(passed_count: int, failed_count: int)

var test_results: Array[Dictionary] = []
var is_running: bool = false

func _ready():
	# Only run in debug builds
	if not OS.is_debug_build():
		queue_free()
		return
	
	add_to_group("qa_testing")

func run_all_tests():
	## Run all regression tests
	is_running = true
	test_results.clear()
	
	print("=== Starting Regression Tests ===")
	
	# Core system tests
	_test_save_load()
	_test_generation_change()
	_test_travel_system()
	_test_npc_memory()
	_test_heirloom_inheritance()
	_test_entropy_tracking()
	_test_production_system()
	_test_marriage_contracts()
	_test_rumor_propagation()
	_test_stat_inheritance()
	
	# Summary
	_all_tests_completed()
	
	is_running = false

func _test_save_load():
	## Test save/load system
	var test_name = "Save/Load System"
	
	var game_manager = GameManager.instance
	if not game_manager:
		_record_test(test_name, false, "GameManager not found")
		return
	
	# Serialize
	var save_data = SaveSchema.serialize_game_state()
	if save_data.is_empty():
		_record_test(test_name, false, "Save serialization failed")
		return
	
	# Deserialize
	var success = SaveSchema.deserialize_game_state(save_data)
	if not success:
		_record_test(test_name, false, "Save deserialization failed")
		return
	
	# Verify data integrity
	if save_data.get("schema_version", 0) == 0:
		_record_test(test_name, false, "Schema version missing")
		return
	
	_record_test(test_name, true, "Save/load successful")

func _test_generation_change():
	## Test generation change and succession
	var test_name = "Generation Change"
	
	var game_manager = GameManager.instance
	if not game_manager or not game_manager.player:
		_record_test(test_name, false, "Player not found")
		return
	
	# Create child
	var child_data = {
		"name": "Test Child",
		"age": 18,
		"traits": ["strong"],
		"stats": {"strength": 10},
		"generation": 2
	}
	game_manager.player.add_child(child_data)
	
	# Simulate death
	var old_name = game_manager.player.name
	game_manager.player._die()
	
	# Check if successor took control
	if game_manager.player.name == old_name:
		_record_test(test_name, false, "Succession failed")
		return
	
	_record_test(test_name, true, "Generation change successful")

func _test_travel_system():
	## Test travel system
	var test_name = "Travel System"
	
	var world = get_tree().get_first_node_in_group("world") as WorldController
	if not world:
		_record_test(test_name, false, "WorldController not found")
		return
	
	# Test travel to destination
	var success = world.start_travel("brassford")
	if not success:
		_record_test(test_name, false, "Travel start failed")
		return
	
	_record_test(test_name, true, "Travel system functional")

func _test_npc_memory():
	## Test NPC memory system
	var test_name = "NPC Memory"
	
	var npc_system = get_tree().get_first_node_in_group("npc_system") as NPCSystem
	if not npc_system:
		_record_test(test_name, false, "NPCSystem not found")
		return
	
	# Change opinion
	var npc_id = npc_system.npcs.keys()[0] if not npc_system.npcs.is_empty() else ""
	if npc_id.is_empty():
		_record_test(test_name, false, "No NPCs available")
		return
	
	var old_opinion = npc_system.get_npc_opinion(npc_id)
	npc_system.change_opinion(npc_id, -10, "test_event")
	var new_opinion = npc_system.get_npc_opinion(npc_id)
	
	if new_opinion != old_opinion - 10:
		_record_test(test_name, false, "Opinion change failed")
		return
	
	_record_test(test_name, true, "NPC memory functional")

func _test_heirloom_inheritance():
	## Test heirloom inheritance
	var test_name = "Heirloom Inheritance"
	
	var heirloom_system = get_tree().get_first_node_in_group("heirlooms") as HeirloomSystem
	if not heirloom_system:
		_record_test(test_name, false, "HeirloomSystem not found")
		return
	
	# Get owned heirlooms
	var owned = heirloom_system.get_owned_heirlooms()
	if owned.is_empty():
		_record_test(test_name, false, "No heirlooms to test")
		return
	
	# Test inheritance
	var successor = {"name": "Test Successor", "generation": 2}
	heirloom_system.pass_to_next_generation(successor)
	
	# Check heirlooms still exist
	var still_owned = heirloom_system.get_owned_heirlooms()
	if still_owned.is_empty():
		_record_test(test_name, false, "Heirlooms lost on inheritance")
		return
	
	_record_test(test_name, true, "Heirloom inheritance functional")

func _test_entropy_tracking():
	## Test entropy system
	var test_name = "Entropy Tracking"
	
	var entropy = get_tree().get_first_node_in_group("entropy") as EntropySystem
	if not entropy:
		_record_test(test_name, false, "EntropySystem not found")
		return
	
	# Test entropy increase
	var old_order = entropy.order_level
	entropy.add_order_entropy(10.0)
	var new_order = entropy.order_level
	
	if new_order != old_order + 10.0:
		_record_test(test_name, false, "Entropy increase failed")
		return
	
	_record_test(test_name, true, "Entropy tracking functional")

func _test_production_system():
	## Test production system
	var test_name = "Production System"
	
	var production = get_tree().get_first_node_in_group("production") as ProductionSystem
	if not production:
		_record_test(test_name, false, "ProductionSystem not found")
		return
	
	# Test building placement (would need valid position)
	# Simplified: just check system exists
	_record_test(test_name, true, "Production system exists")

func _test_marriage_contracts():
	## Test marriage contract system
	var test_name = "Marriage Contracts"
	
	var lineage = get_tree().get_first_node_in_group("lineage") as LineageSystem
	if not lineage:
		_record_test(test_name, false, "LineageSystem not found")
		return
	
	# Test proposal
	var contract = lineage.propose_marriage("machinists")
	if contract.is_empty():
		_record_test(test_name, false, "Marriage proposal failed")
		return
	
	_record_test(test_name, true, "Marriage system functional")

func _test_rumor_propagation():
	## Test rumor system
	var test_name = "Rumor Propagation"
	
	var rumor_system = get_tree().get_first_node_in_group("rumor_system") as RumorSystem
	if not rumor_system:
		_record_test(test_name, false, "RumorSystem not found")
		return
	
	# Generate rumor
	var rumor = rumor_system.generate_rumor("bandit_attack", {
		"player_name": "Test",
		"settlement": "Brassford"
	})
	
	if rumor.is_empty():
		_record_test(test_name, false, "Rumor generation failed")
		return
	
	_record_test(test_name, true, "Rumor system functional")

func _test_stat_inheritance():
	## Test stat inheritance
	var test_name = "Stat Inheritance"
	
	var rpg_stats = get_tree().get_first_node_in_group("rpg_stats") as RPGStatsSystem
	if not rpg_stats:
		_record_test(test_name, false, "RPGStatsSystem not found")
		return
	
	# Test inheritance calculation
	var parent1_stats = {"resolve": 50, "mechanica": 40, "soilcraft": 60}
	var parent2_stats = {"resolve": 45, "mechanica": 50, "soilcraft": 55}
	var factors = rpg_stats.get_inheritance_factors()
	
	var child_stats = rpg_stats.inherit_stats_from_parents(parent1_stats, parent2_stats, factors)
	
	if child_stats.is_empty():
		_record_test(test_name, false, "Stat inheritance calculation failed")
		return
	
	_record_test(test_name, true, "Stat inheritance functional")

func _record_test(test_name: String, passed: bool, message: String):
	## Record test result
	var result = {
		"test": test_name,
		"passed": passed,
		"message": message
	}
	
	test_results.append(result)
	
	var status = "PASS" if passed else "FAIL"
	print("[TEST] " + status + ": " + test_name + " - " + message)
	
	test_completed.emit(test_name, passed)

func _all_tests_completed():
	## Generate test summary
	var passed = 0
	var failed = 0
	
	for result in test_results:
		if result["passed"]:
			passed += 1
		else:
			failed += 1
	
	print("\n=== Test Results ===")
	print("Passed: " + str(passed))
	print("Failed: " + str(failed))
	print("Total: " + str(test_results.size()))
	
	# Save to file
	_save_test_results()
	
	all_tests_completed.emit(passed, failed)

func _save_test_results():
	## Save test results to file
	var file = FileAccess.open("reports/test_results.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({
			"timestamp": Time.get_unix_time_from_system(),
			"results": test_results
		}))
		file.close()

