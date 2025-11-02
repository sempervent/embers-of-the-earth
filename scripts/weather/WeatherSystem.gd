extends Node2D
class_name WeatherSystem

## Procedural weather system for atmospheric effects
## Manages ash, steam, lightning, wind, and their visual/audio effects

signal weather_changed(weather_type: String)
signal weather_intensity_changed(intensity: float)

enum WeatherType {
	CLEAR,
	ASH_FALL,
	DUST_STORM,
	STATIC_STORM,
	STEAM_FOG,
	DRY_WIND
}

var current_weather: WeatherType = WeatherType.CLEAR
var weather_intensity: float = 0.0  # 0.0 to 1.0
var weather_duration: float = 0.0  # Time remaining in seconds
var weather_transition_time: float = 5.0  # Transition duration

# Weather probabilities (modified by game state)
var weather_weights: Dictionary = {
	WeatherType.CLEAR: 40.0,
	WeatherType.ASH_FALL: 15.0,
	WeatherType.DUST_STORM: 10.0,
	WeatherType.STATIC_STORM: 8.0,
	WeatherType.STEAM_FOG: 15.0,
	WeatherType.DRY_WIND: 12.0
}

# Weather parameters
var wind_direction: float = 0.0  # Degrees (0 = right, 90 = down)
var wind_speed: float = 0.0  # 0.0 to 1.0
var steam_vent_positions: Array[Vector2] = []
var lightning_timer: float = 0.0

# Particle systems for visual effects
var particle_systems: Dictionary = {}
var weather_effects_node: Node2D

# References to other systems
var ambient_sound: AmbientSoundManager
var procedural_music: ProceduralMusic
var visual_effects: Node  # VisualEffectsSystem

func _ready():
	weather_effects_node = Node2D.new()
	weather_effects_node.name = "WeatherEffects"
	add_child(weather_effects_node)
	
	_initialize_particle_systems()
	_start_weather_cycle()

func _initialize_particle_systems():
	## Create particle systems for each weather type
	var ash_particles = GPUParticles2D.new()
	ash_particles.name = "AshParticles"
	ash_particles.emitting = false
	weather_effects_node.add_child(ash_particles)
	particle_systems[WeatherType.ASH_FALL] = ash_particles
	
	var dust_particles = GPUParticles2D.new()
	dust_particles.name = "DustParticles"
	dust_particles.emitting = false
	weather_effects_node.add_child(dust_particles)
	particle_systems[WeatherType.DUST_STORM] = dust_particles
	
	var steam_particles = GPUParticles2D.new()
	steam_particles.name = "SteamParticles"
	steam_particles.emitting = false
	weather_effects_node.add_child(steam_particles)
	particle_systems[WeatherType.STEAM_FOG] = steam_particles
	
	# Lightning effect (not particles, but visual effect)
	# Would use a shader or sprite animation

func _start_weather_cycle():
	## Start the weather change cycle
	_change_weather()
	
	# Schedule next weather change (random interval)
	var next_change_time = randf_range(30.0, 120.0)
	get_tree().create_timer(next_change_time).timeout.connect(_start_weather_cycle)

func _change_weather():
	## Change to a new random weather type
	var new_weather = _select_random_weather()
	var new_intensity = randf_range(0.3, 1.0)
	var new_duration = randf_range(20.0, 60.0)
	
	_transition_to_weather(new_weather, new_intensity, new_duration)

func _select_random_weather() -> WeatherType:
	## Select weather type based on weighted probabilities
	var total_weight = 0.0
	for weight in weather_weights.values():
		total_weight += weight
	
	var rand_val = randf() * total_weight
	var cumulative = 0.0
	
	for weather_type in WeatherType.values():
		cumulative += weather_weights.get(weather_type, 0.0)
		if rand_val <= cumulative:
			return weather_type
	
	return WeatherType.CLEAR

func _transition_to_weather(weather_type: WeatherType, intensity: float, duration: float):
	## Transition to new weather type
	var old_weather = current_weather
	current_weather = weather_type
	weather_intensity = intensity
	weather_duration = duration
	
	# Fade out old weather effects
	_fade_out_weather_effects(old_weather)
	
	# Fade in new weather effects
	_fade_in_weather_effects(weather_type, intensity)
	
	# Update music and sound
	_update_audio_for_weather(weather_type)
	
	weather_changed.emit(WeatherType.keys()[weather_type])
	weather_intensity_changed.emit(intensity)

func _fade_out_weather_effects(weather_type: WeatherType):
	## Fade out effects for old weather
	var particles = particle_systems.get(weather_type)
	if particles:
		particles.emitting = false

func _fade_in_weather_effects(weather_type: WeatherType, intensity: float):
	## Fade in effects for new weather
	match weather_type:
		WeatherType.ASH_FALL:
			_start_ash_fall(intensity)
		WeatherType.DUST_STORM:
			_start_dust_storm(intensity)
		WeatherType.STATIC_STORM:
			_start_static_storm(intensity)
		WeatherType.STEAM_FOG:
			_start_steam_fog(intensity)
		WeatherType.DRY_WIND:
			_start_dry_wind(intensity)
		_:
			_clear_weather()

func _start_ash_fall(intensity: float):
	## Start ash fall particle effect
	var particles = particle_systems.get(WeatherType.ASH_FALL)
	if particles:
		# Configure particles for ash
		particles.amount = int(500 * intensity)
		particles.emitting = true
		
		# Configure particle properties
		var material = ParticlesMaterial.new()
		material.gravity = Vector3(0, -98, 0)
		material.initial_velocity_min = 50.0
		material.initial_velocity_max = 100.0
		material.color = Color(0.2, 0.2, 0.2, 0.8)  # Dark ash color
		particles.process_material = material
	
	# Update wind for ash drift
	wind_speed = intensity * 0.5
	wind_direction = randf() * 360.0

func _start_dust_storm(intensity: float):
	## Start dust storm effect
	var particles = particle_systems.get(WeatherType.DUST_STORM)
	if particles:
		particles.amount = int(800 * intensity)
		particles.emitting = true
		
		var material = ParticlesMaterial.new()
		material.gravity = Vector3(0, -20, 0)
		material.initial_velocity_min = 100.0
		material.initial_velocity_max = 200.0
		material.color = Color(0.6, 0.5, 0.3, 0.9)  # Dusty brown
		particles.process_material = material
	
	wind_speed = intensity
	wind_direction = randf() * 360.0
	
	# Trigger music change
	if procedural_music:
		procedural_music.update_condition("weather", "dust_storm")

func _start_static_storm(intensity: float):
	## Start static storm (lightning without rain)
	lightning_timer = 0.0
	
	# Create lightning effect periodically
	_trigger_lightning()
	
	# Update visual effects
	if visual_effects:
		visual_effects.start_static_effect(intensity)
	
	# Update audio
	if ambient_sound:
		ambient_sound.play_event_sound("static_crack")

func _start_steam_fog(intensity: float):
	## Start steam fog effect
	var particles = particle_systems.get(WeatherType.STEAM_FOG)
	if particles:
		particles.amount = int(300 * intensity)
		particles.emitting = true
		
		var material = ParticlesMaterial.new()
		material.gravity = Vector3(0, -10, 0)
		material.initial_velocity_min = 20.0
		material.initial_velocity_max = 40.0
		material.color = Color(0.8, 0.8, 0.8, 0.6)  # Steam white
		particles.process_material = material
	
	# Enable steam sounds
	if ambient_sound:
		ambient_sound.set_steam_active(true)

func _start_dry_wind(intensity: float):
	## Start dry wind effect
	wind_speed = intensity * 0.8
	wind_direction = randf() * 360.0
	
	# Update wind sounds
	if ambient_sound:
		ambient_sound.set_wind_strength(wind_speed)
	
	# Crop bending visual effect (handled by visual effects system)

func _clear_weather():
	## Clear all weather effects
	for particles in particle_systems.values():
		particles.emitting = false
	
	if ambient_sound:
		ambient_sound.set_wind_strength(0.0)
		ambient_sound.set_steam_active(false)

func _update_audio_for_weather(weather_type: WeatherType):
	## Update audio systems for weather change
	var weather_name = WeatherType.keys()[weather_type].to_lower()
	
	if procedural_music:
		procedural_music.update_condition("weather", weather_name)
	
	if ambient_sound:
		match weather_type:
			WeatherType.DUST_STORM:
				ambient_sound.set_wind_strength(0.9)
			WeatherType.DRY_WIND:
				ambient_sound.set_wind_strength(0.6)
			_:
				ambient_sound.set_wind_strength(0.3)

func _trigger_lightning():
	## Trigger a lightning flash
	if visual_effects:
		visual_effects.flash_lightning()
	
	# Schedule next lightning
	if weather_intensity > 0.5:
		var next_lightning = randf_range(2.0, 8.0)
		get_tree().create_timer(next_lightning).timeout.connect(_trigger_lightning)

func _process(delta):
	## Update weather effects
	weather_duration -= delta
	
	if weather_duration <= 0.0:
		# Weather ended, transition to clear
		_transition_to_weather(WeatherType.CLEAR, 0.0, 0.0)

func get_wind_direction() -> float:
	## Get current wind direction in degrees
	return wind_direction

func get_wind_speed() -> float:
	## Get current wind speed (0.0 to 1.0)
	return wind_speed

func get_current_weather() -> WeatherType:
	return current_weather

func get_weather_intensity() -> float:
	return weather_intensity

