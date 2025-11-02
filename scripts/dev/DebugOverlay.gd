extends Control
class_name DebugOverlay

## Debug overlay showing FPS, entropy, tile mood heatmap, etc.

var show_overlay: bool = false
var show_heatmap: bool = false

@onready var info_label: Label = $InfoLabel
@onready var heatmap_layer: CanvasLayer = $HeatmapLayer

var game_manager: GameManager

func _ready():
	set_visible(false)
	add_to_group("debug_overlay")
	
	# Only show in dev builds
	if not OS.is_debug_build():
		queue_free()
		return
	
	game_manager = GameManager.instance

func _input(event):
	if event.is_action_pressed("toggle_debug"):
		show_overlay = !show_overlay
		set_visible(show_overlay)
	
	if event.is_action_pressed("toggle_heatmap"):
		show_heatmap = !show_heatmap
		if heatmap_layer:
			heatmap_layer.visible = show_heatmap

func _process(_delta):
	if not show_overlay:
		return
	
	if not info_label:
		return
	
	var info_text = ""
	
	# FPS
	info_text += "FPS: " + str(Engine.get_frames_per_second()) + "\n"
	
	# Day/Year
	info_text += "Day: " + str(GameManager.current_day) + " Year: " + str(GameManager.current_year) + "\n"
	
	# Player
	if game_manager and game_manager.player:
		info_text += "Player: " + game_manager.player.name + " (Age " + str(game_manager.player.age) + ")\n"
	
	# Entropy
	var entropy = get_tree().get_first_node_in_group("entropy") as EntropySystem
	if entropy:
		info_text += "Entropy - Order: " + str(int(entropy.order_level)) + " Wild: " + str(int(entropy.wild_level)) + "\n"
	
	# RNG Seed
	info_text += "Seed: " + str(randi()) + "\n"
	
	# Weather
	var atmosphere = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	if atmosphere and atmosphere.weather_system:
		var weather_type = WeatherSystem.WeatherType.keys()[atmosphere.weather_system.current_weather]
		info_text += "Weather: " + weather_type + " (Intensity: " + str(atmosphere.weather_system.weather_intensity) + ")\n"
	
	info_label.text = info_text
	
	# Update heatmap if visible
	if show_heatmap:
		_draw_heatmap()

func _draw_heatmap():
	## Draw tile mood heatmap
	if not game_manager or not game_manager.farm_grid:
		return
	
	# Would draw colored rectangles over tiles based on mood
	# Simplified: just queue redraw
	queue_redraw()

