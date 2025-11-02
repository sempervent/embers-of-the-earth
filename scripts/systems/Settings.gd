extends Node
class_name Settings

## Game settings with real-time updates

signal setting_changed(setting_name: String, value)

var settings: Dictionary = {
	"audio": {
		"master_volume": 1.0,
		"music_volume": 0.8,
		"ambient_volume": 0.7,
		"sfx_volume": 1.0
	},
	"gameplay": {
		"encounter_rate": 0.5,
		"difficulty": "normal",
		"day_speed": 1.0
	},
	"accessibility": {
		"colorblind_mode": false,
		"text_size": "medium",
		"reduce_motion": false
	},
	"visual": {
		"particle_effects": true,
		"weather_intensity": 1.0,
		"ui_scale": 1.0
	}
}

func _ready():
	_load_settings()

func set_setting(category: String, key: String, value):
	## Set a setting value
	if not settings.has(category):
		settings[category] = {}
	
	settings[category][key] = value
	setting_changed.emit(category + "." + key, value)
	_apply_setting(category, key, value)
	_save_settings()

func get_setting(category: String, key: String, default = null):
	## Get a setting value
	if not settings.has(category):
		return default
	if not settings[category].has(key):
		return default
	return settings[category][key]

func _apply_setting(category: String, key: String, value):
	## Apply setting to game systems
	if category == "audio":
		_apply_audio_setting(key, value)
	elif category == "gameplay":
		_apply_gameplay_setting(key, value)
	elif category == "visual":
		_apply_visual_setting(key, value)

func _apply_audio_setting(key: String, value):
	## Apply audio settings
	var atmosphere = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	if not atmosphere:
		return
	
	match key:
		"master_volume":
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
		"music_volume":
			if atmosphere.procedural_music:
				for player in atmosphere.procedural_music.audio_players.values():
					player.volume_db = linear_to_db(value * get_setting("audio", "master_volume", 1.0))
		"ambient_volume":
			if atmosphere.ambient_sound:
				for player in atmosphere.ambient_sound.ambient_players.values():
					player.volume_db = linear_to_db(value * get_setting("audio", "master_volume", 1.0))

func _apply_gameplay_setting(key: String, value):
	## Apply gameplay settings
	match key:
		"encounter_rate":
			# Would adjust encounter table weights
			pass
		"difficulty":
			# Would adjust various game parameters
			pass

func _apply_visual_setting(key: String, value):
	## Apply visual settings
	var atmosphere = get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	if not atmosphere:
		return
	
	match key:
		"particle_effects":
			if atmosphere.visual_effects:
				# Would enable/disable particles
				pass
		"weather_intensity":
			if atmosphere.weather_system:
				# Would scale weather effects
				pass

func _save_settings():
	## Save settings to file
	var file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	if file == null:
		push_warning("Failed to save settings")
		return
	
	file.store_string(JSON.stringify(settings))
	file.close()

func _load_settings():
	## Load settings from file
	if not FileAccess.file_exists("user://settings.json"):
		return
	
	var file = FileAccess.open("user://settings.json", FileAccess.READ)
	if file == null:
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Settings parse error: " + json.get_error_message())
		return
	
	var loaded_settings = json.get_data()
	
	# Merge with defaults
	for category in loaded_settings:
		if settings.has(category):
			for key in loaded_settings[category]:
				settings[category][key] = loaded_settings[category][key]
				_apply_setting(category, key, loaded_settings[category][key])

