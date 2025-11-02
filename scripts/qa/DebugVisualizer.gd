extends CanvasLayer
class_name DebugVisualizer

## Debug visualizations for resource flow, entropy, NPC opinions

signal visualization_toggled(viz_type: String, visible: bool)

var visualizations: Dictionary = {
	"resource_flow": false,
	"entropy_trajectory": false,
	"npc_opinions": false,
	"tile_mood_heatmap": false
}

@onready var resource_overlay: Control = $ResourceOverlay
@onready var entropy_graph: Control = $EntropyGraph
@onready var npc_map: Control = $NPCMap
@onready var heatmap_overlay: Control = $HeatmapOverlay

var game_manager: GameManager
var entropy_history: Array[Dictionary] = []  # Track entropy over time

func _ready():
	if not OS.is_debug_build():
		queue_free()
		return
	
	game_manager = GameManager.instance
	set_visible(false)
	add_to_group("debug_viz")

func _input(event):
	if event.is_action_pressed("toggle_resource_viz"):
		toggle_visualization("resource_flow")
	if event.is_action_pressed("toggle_entropy_viz"):
		toggle_visualization("entropy_trajectory")
	if event.is_action_pressed("toggle_npc_viz"):
		toggle_visualization("npc_opinions")
	if event.is_action_pressed("toggle_heatmap_viz"):
		toggle_visualization("tile_mood_heatmap")

func toggle_visualization(viz_type: String):
	## Toggle visualization
	if not visualizations.has(viz_type):
		return
	
	visualizations[viz_type] = !visualizations[viz_type]
	visualization_toggled.emit(viz_type, visualizations[viz_type])
	
	# Show/hide visualization
	_update_visualization(viz_type)

func _update_visualization(viz_type: String):
	## Update visualization display
	match viz_type:
		"resource_flow":
			if resource_overlay:
				resource_overlay.visible = visualizations[viz_type]
			_draw_resource_flow()
		
		"entropy_trajectory":
			if entropy_graph:
				entropy_graph.visible = visualizations[viz_type]
			_draw_entropy_trajectory()
		
		"npc_opinions":
			if npc_map:
				npc_map.visible = visualizations[viz_type]
			_draw_npc_opinions()
		
		"tile_mood_heatmap":
			if heatmap_overlay:
				heatmap_overlay.visible = visualizations[viz_type]
			_draw_tile_mood_heatmap()

func _draw_resource_flow():
	## Draw resource flow visualization
	if not resource_overlay:
		return
	
	resource_overlay.queue_redraw()
	
	# Would draw arrows showing resource flow between systems
	# Player inventory → Farm → Production → Settlement

func _draw_entropy_trajectory():
	## Draw entropy trajectory graph
	if not entropy_graph:
		return
	
	var entropy = get_tree().get_first_node_in_group("entropy") as EntropySystem
	if not entropy:
		return
	
	# Record current entropy
	entropy_history.append({
		"year": GameManager.current_year,
		"order": entropy.order_level,
		"wild": entropy.wild_level
	})
	
	# Keep only last 100 data points
	if entropy_history.size() > 100:
		entropy_history.pop_front()
	
	# Draw graph (would use Line2D or custom drawing)
	entropy_graph.queue_redraw()

func _draw_npc_opinions():
	## Draw NPC opinion map
	if not npc_map:
		return
	
	var npc_system = get_tree().get_first_node_in_group("npc_system") as NPCSystem
	if not npc_system:
		return
	
	# Would draw settlement map with NPC opinion indicators
	# Green = positive, Red = negative, Yellow = neutral
	npc_map.queue_redraw()

func _draw_tile_mood_heatmap():
	## Draw tile mood heatmap
	if not game_manager or not game_manager.farm_grid:
		return
	
	# Would overlay color-coded mood indicators on tiles
	# Content = green, Tired = yellow, Resentful = red
	heatmap_overlay.queue_redraw()

func _process(_delta):
	## Update visualizations
	if visualizations.get("entropy_trajectory", false):
		_draw_entropy_trajectory()
	if visualizations.get("tile_mood_heatmap", false):
		_draw_tile_mood_heatmap()

