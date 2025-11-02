extends Node2D
class_name VisualEffects

## Visual effects system for atmosphere
## Handles particles, shaders, parallax, and post-processing

signal effect_triggered(effect_name: String)

# Post-processing effects
var canvas_modulate: CanvasModulate
var vignette_shader: ShaderMaterial
var dust_overlay: ColorRect

# Particle systems
var steam_vents: Array[GPUParticles2D] = []
var light_rays: Node2D

# Parallax layers
var parallax_background: ParallaxBackground
var ash_clouds_layer: ParallaxLayer
var pollen_layer: ParallaxLayer

# UI effects
var ui_flicker_timer: float = 0.0
var ui_lamp_nodes: Array[Control] = []

# Crop bending (wind effect)
var crop_shader: ShaderMaterial

func _ready():
	_setup_post_processing()
	_setup_particles()
	_setup_parallax()
	_start_effects()

func _setup_post_processing():
	## Setup post-processing effects (dust, vignette, fog)
	canvas_modulate = CanvasModulate.new()
	canvas_modulate.color = Color(0.9, 0.85, 0.8, 1.0)  # Slight desaturation
	add_child(canvas_modulate)
	
	# Vignette effect (darker edges)
	vignette_shader = preload("res://shaders/vignette.gdshader") if ResourceLoader.exists("res://shaders/vignette.gdshader") else null
	# Would apply to a ColorRect with shader material
	
	# Dust overlay (slight color tint)
	dust_overlay = ColorRect.new()
	dust_overlay.color = Color(0.7, 0.6, 0.5, 0.1)  # Dusty overlay
	dust_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dust_overlay)

func _setup_particles():
	## Setup particle systems for steam vents, etc.
	# Steam vents will be created dynamically from farm tiles
	pass

func _setup_parallax():
	## Setup parallax layers for background atmosphere
	parallax_background = ParallaxBackground.new()
	add_child(parallax_background)
	
	# Ash clouds layer
	ash_clouds_layer = ParallaxLayer.new()
	ash_clouds_layer.motion_scale = Vector2(0.5, 0.5)
	parallax_background.add_child(ash_clouds_layer)
	
	# Pollen layer
	pollen_layer = ParallaxLayer.new()
	pollen_layer.motion_scale = Vector2(0.3, 0.3)
	parallax_background.add_child(pollen_layer)

func _start_effects():
	## Start continuous visual effects
	# Start steam vents (will be positioned by farm tiles)
	_create_steam_vent(Vector2(100, 100))
	
	# Start UI flicker
	_start_ui_flicker()

func _start_ui_flicker():
	## Flicker UI lamps based on wind/weather
	if ui_lamp_nodes.is_empty():
		# Find UI lamp nodes (would be tagged in UI)
		pass
	
	# Periodic flicker
	_trigger_ui_flicker()
	var next_flicker = randf_range(3.0, 10.0)
	get_tree().create_timer(next_flicker).timeout.connect(_start_ui_flicker)

func _trigger_ui_flicker():
	## Trigger UI lamp flicker effect
	for lamp in ui_lamp_nodes:
		if lamp:
			# Flicker modulation
			var tween = create_tween()
			tween.tween_property(lamp, "modulate", Color(0.8, 0.8, 0.8, 1.0), 0.1)
			tween.tween_property(lamp, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)

func _create_steam_vent(position: Vector2):
	## Create a steam vent particle system at position
	var particles = GPUParticles2D.new()
	particles.position = position
	particles.emitting = true
	particles.amount = 50
	
	var material = ParticlesMaterial.new()
	material.gravity = Vector3(0, -30, 0)
	material.initial_velocity_min = 20.0
	material.initial_velocity_max = 40.0
	material.color = Color(0.9, 0.9, 0.9, 0.7)
	particles.process_material = material
	
	add_child(particles)
	steam_vents.append(particles)

func flash_lightning():
	## Flash screen for lightning effect
	var flash = ColorRect.new()
	flash.color = Color(1.0, 1.0, 1.0, 0.8)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.anchor_right = 1.0
	flash.anchor_bottom = 1.0
	add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.2)
	tween.tween_callback(flash.queue_free)

func start_static_effect(intensity: float):
	## Start static storm visual effect
	# Could add screen distortion, sparks, etc.
	pass

func apply_crop_bend(tile_position: Vector2, wind_direction: float, wind_speed: float):
	## Apply wind bending effect to crops
	# Would use shader or sprite rotation based on wind
	pass

func apply_light_rays(direction: Vector2, intensity: float):
	## Create light rays (dawn light through broken roofs)
	# Would use Line2D or shader for ray effect
	pass

func set_time_of_day_modulation(time: String):
	## Adjust canvas modulate based on time of day
	match time:
		"morning":
			canvas_modulate.color = Color(1.0, 0.95, 0.9, 1.0)  # Warm morning
		"noon":
			canvas_modulate.color = Color(1.0, 1.0, 0.95, 1.0)  # Bright
		"evening":
			canvas_modulate.color = Color(0.95, 0.85, 0.8, 1.0)  # Golden hour
		"night":
			canvas_modulate.color = Color(0.6, 0.65, 0.7, 1.0)  # Cool night

func add_ui_lamp(lamp_node: Control):
	## Register a UI lamp for flicker effects
	ui_lamp_nodes.append(lamp_node)

