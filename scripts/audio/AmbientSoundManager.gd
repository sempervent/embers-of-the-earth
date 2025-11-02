extends Node
class_name AmbientSoundManager

## Manages ambient environmental sounds
## Handles dynamic sound layering and spatial audio

signal sound_event(event_name: String, position: Vector2)

# Sound categories
var ambient_loops: Dictionary = {}  # Continuous background sounds
var event_sounds: Dictionary = {}    # One-shot sounds
var spatial_sounds: Dictionary = {} # Positional sounds

# Audio players
var ambient_players: Dictionary = {}
var event_players: Dictionary = {}

# Sound conditions
var conditions: Dictionary = {
	"time_of_day": "morning",
	"weather": "clear",
	"wind_strength": 0.0,  # 0.0 to 1.0
	"steam_active": false,
	"machinery_running": false
}

# Volume levels
var ambient_volume: float = -10.0  # dB
var event_volume: float = 0.0

func _ready():
	_initialize_audio_players()
	_start_ambient_loops()

func _initialize_audio_players():
	## Create audio players for ambient and event sounds
	# Ambient loops
	var ambient_types = ["wind", "steam", "machinery", "crickets", "distant_pipes"]
	for sound_type in ambient_types:
		var player = AudioStreamPlayer.new()
		player.name = "Ambient_" + sound_type.capitalize()
		player.volume_db = ambient_volume
		add_child(player)
		ambient_players[sound_type] = player
	
	# Event sounds
	var event_types = ["valve_click", "gear_click", "owl_gear", "heartbeat", "soil_pulse"]
	for sound_type in event_types:
		var player = AudioStreamPlayer.new()
		player.name = "Event_" + sound_type.capitalize()
		player.volume_db = event_volume
		add_child(player)
		event_players[sound_type] = player

func _start_ambient_loops():
	## Start appropriate ambient loops based on conditions
	_update_ambient_sounds()

func update_condition(condition_name: String, value):
	## Update a sound condition
	if conditions.has(condition_name):
		conditions[condition_name] = value
		_update_ambient_sounds()

func _update_ambient_sounds():
	## Update which ambient sounds are playing
	# Wind - based on wind strength
	var wind_player = ambient_players.get("wind")
	if wind_player:
		if conditions.wind_strength > 0.1:
			wind_player.volume_db = ambient_volume + (conditions.wind_strength * 10.0)
			if not wind_player.playing:
				# wind_player.stream = load("res://assets/sounds/ambient/wind.ogg")
				# wind_player.play()
				pass
		else:
			wind_player.stop()
	
	# Steam - if steam is active
	var steam_player = ambient_players.get("steam")
	if steam_player:
		if conditions.steam_active:
			if not steam_player.playing:
				# steam_player.stream = load("res://assets/sounds/ambient/steam_hiss.ogg")
				# steam_player.play()
				pass
		else:
			steam_player.stop()
	
	# Crickets - at night
	var cricket_player = ambient_players.get("crickets")
	if cricket_player:
		if conditions.time_of_day == "night":
			if not cricket_player.playing:
				# cricket_player.stream = load("res://assets/sounds/ambient/crickets.ogg")
				# cricket_player.play()
				pass
		else:
			cricket_player.stop()
	
	# Distant pipes - always slightly present
	var pipes_player = ambient_players.get("distant_pipes")
	if pipes_player:
		if not pipes_player.playing:
			# pipes_player.stream = load("res://assets/sounds/ambient/distant_pipes.ogg")
			# pipes_player.volume_db = ambient_volume - 20.0  # Very quiet
			# pipes_player.play()
			pass

func play_event_sound(sound_name: String, position: Vector2 = Vector2.ZERO):
	## Play a one-shot sound event
	var player = event_players.get(sound_name)
	if player:
		# If position provided, make it spatial
		if position != Vector2.ZERO:
			_play_spatial_sound(sound_name, position)
		else:
			# player.stream = load("res://assets/sounds/events/" + sound_name + ".ogg")
			# player.play()
			pass
		sound_event.emit(sound_name, position)

func _play_spatial_sound(sound_name: String, position: Vector2):
	## Play a spatial sound at the given position
	# Would use AudioStreamPlayer2D or AudioStreamPlayer3D
	# For now, just triggers the sound
	pass

func play_mechanical_tick():
	## Play a mechanical ticking sound (valves, gears)
	var tick_type = "valve_click" if randf() > 0.5 else "gear_click"
	play_event_sound(tick_type)

func play_soil_pulse():
	## Play a heartbeat-like pulse from overused soil
	play_event_sound("soil_pulse")

func set_wind_strength(strength: float):
	## Set wind strength (0.0 to 1.0)
	conditions.wind_strength = clamp(strength, 0.0, 1.0)
	update_condition("wind_strength", conditions.wind_strength)

func set_steam_active(active: bool):
	## Enable/disable steam sounds
	conditions.steam_active = active
	update_condition("steam_active", active)

func fade_out_all(duration: float = 2.0):
	## Fade out all sounds
	var tween = create_tween()
	for player in ambient_players.values():
		if player.playing:
			tween.parallel().tween_property(player, "volume_db", -80.0, duration)
	for player in event_players.values():
		if player.playing:
			tween.parallel().tween_property(player, "volume_db", -80.0, duration)

