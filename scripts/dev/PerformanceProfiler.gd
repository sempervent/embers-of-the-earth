extends Node
class_name PerformanceProfiler

## Performance profiler with frame time tracking and warnings

signal performance_warning(metric: String, value: float, threshold: float)

var frame_times: Array[float] = []
var max_frame_time_history: int = 120  # Last 2 seconds at 60 FPS

var tile_update_count: int = 0
var npc_count: int = 0
var rumor_count: int = 0
var production_queue_size: int = 0

var frame_time_warning_threshold: float = 16.67  # 60 FPS = 16.67ms
var consecutive_warning_frames: int = 30
var warning_count: int = 0

var is_profiling: bool = false
var debug_overlay_enabled: bool = false

func _ready():
	# Only run in debug builds
	if not OS.is_debug_build():
		queue_free()
		return
	
	add_to_group("performance_profiler")
	process_mode = PROCESS_MODE_ALWAYS

func _process(delta: float):
	if not is_profiling:
		return
	
	# Track frame time
	var frame_time_ms = delta * 1000.0
	frame_times.append(frame_time_ms)
	
	if frame_times.size() > max_frame_time_history:
		frame_times.pop_front()
	
	# Check for performance warnings
	_check_frame_time_warnings(frame_time_ms)
	
	# Update metrics
	_update_metrics()

func start_profiling():
	## Start performance profiling
	is_profiling = true
	frame_times.clear()
	warning_count = 0
	print("Performance profiling started.")

func stop_profiling():
	## Stop performance profiling
	is_profiling = false
	print("Performance profiling stopped.")

func toggle_debug_overlay():
	## Toggle debug overlay display
	debug_overlay_enabled = not debug_overlay_enabled
	# Debug overlay is internal to profiler, no need to emit signal

func _check_frame_time_warnings(current_frame_time: float):
	## Check if frame time exceeds threshold for consecutive frames
	if current_frame_time > frame_time_warning_threshold:
		warning_count += 1
		
		if warning_count >= consecutive_warning_frames:
			performance_warning.emit("frame_time", current_frame_time, frame_time_warning_threshold)
			push_warning("Performance warning: Frame time > 16.67ms for ", warning_count, " consecutive frames.")
			warning_count = 0  # Reset after warning
	else:
		warning_count = 0

func _update_metrics():
	## Update performance metrics from game systems
	var game_manager = GameManager.instance if GameManager.instance else null
	
	# Tile update count
	if game_manager and game_manager.farm_grid:
		tile_update_count = game_manager.farm_grid.tiles.size()
	
	# NPC count
	var npc_system = get_tree().get_first_node_in_group("npc_system") as NPCSystem
	if npc_system:
		npc_count = npc_system.npcs.size()
	
	# Rumor count
	var rumor_system = get_tree().get_first_node_in_group("rumor_system") as RumorSystem
	if rumor_system:
		var active_rumors = rumor_system.get_current_rumors()
		rumor_count = active_rumors.size() if active_rumors else 0
	
	# Production queue size
	var production = get_tree().get_first_node_in_group("production") as ProductionSystem
	if production:
		var total_queue_size = 0
		for building in production.buildings.values():
			var queue = building.get("recipe_queue", [])
			total_queue_size += queue.size() if queue else 0
		production_queue_size = total_queue_size

func get_average_frame_time() -> float:
	## Get average frame time over history
	if frame_times.is_empty():
		return 0.0
	
	var sum = 0.0
	for ft in frame_times:
		sum += ft
	return sum / frame_times.size()

func get_max_frame_time() -> float:
	## Get maximum frame time over history
	if frame_times.is_empty():
		return 0.0
	
	var max_ft = 0.0
	for ft in frame_times:
		if ft > max_ft:
			max_ft = ft
	return max_ft

func get_fps() -> float:
	## Get current FPS estimate
	var avg_frame_time = get_average_frame_time()
	if avg_frame_time == 0.0:
		return 60.0
	return 1000.0 / avg_frame_time

func get_performance_summary() -> Dictionary:
	## Get comprehensive performance summary
	return {
		"fps": get_fps(),
		"avg_frame_time_ms": get_average_frame_time(),
		"max_frame_time_ms": get_max_frame_time(),
		"tile_update_count": tile_update_count,
		"npc_count": npc_count,
		"rumor_count": rumor_count,
		"production_queue_size": production_queue_size,
		"memory_usage_mb": OS.get_static_memory_usage() / 1024.0 / 1024.0
	}

func _input(event):
	## Toggle debug overlay with F3 key
	if event.is_action_pressed("toggle_debug_overlay"):
		toggle_debug_overlay()

