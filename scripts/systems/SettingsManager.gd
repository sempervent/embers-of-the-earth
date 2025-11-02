extends Node
# Note: Can't use class_name for autoload singletons in Godot
# class_name SettingsManager

## Global settings manager with persistence and accessibility options

signal settings_loaded()
signal settings_changed(setting_key: String, new_value: Variant)
signal accessibility_toggled(option: String, enabled: bool)

var settings: Dictionary = {
	"audio": {
		"music_volume": 0.8,
		"ambient_volume": 0.6,
		"sfx_volume": 0.7
	},
	"display": {
		"fullscreen": false,
		"windowed": true,
		"resolution": {"width": 1280, "height": 720}
	},
	"accessibility": {
		"ui_scale": 1.0,
		"reduced_motion": false,
		"colorblind_mode": "none",
		"high_contrast": false,
		"subtitles_enabled": false
	},
	"input": {
		"keybindings": {},
		"controller_enabled": false
	}
}

const FilePathManager = preload("res://scripts/platform/FilePathManager.gd")

func _ready():
	add_to_group("settings")
	
	# Load settings on startup
	load_settings()
	
	# Apply settings immediately
	apply_settings()

func load_settings():
	## Load settings from persistent storage
	var settings_path = FilePathManager.get_settings_path()
	
	if not FileAccess.file_exists(settings_path):
		push_warning("Settings file not found. Using defaults.")
		_save_settings()  # Create default settings file
		return
	
	var file = FileAccess.open(settings_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open settings file. Using defaults.")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_string) != OK:
		push_error("Failed to parse settings file. Using defaults.")
		return
	
	var loaded_settings = json.get_data()
	
	# Merge loaded settings with defaults (handle missing keys)
	_merge_settings(loaded_settings)
	
	settings_loaded.emit()
	print("Settings loaded from: ", settings_path)

func save_settings():
	## Save settings to persistent storage
	_save_settings()

func _save_settings():
	## Internal save method
	var settings_path = FilePathManager.get_settings_path()
	
	# Ensure directory exists
	var settings_dir = FilePathManager.get_settings_directory()
	var dir = DirAccess.open("user://")
	if dir:
		# Create subdirectories if needed (FilePathManager handles absolute paths)
		# For user:// paths, ensure directory structure exists
		var relative_path = settings_dir.replace("user://", "") if settings_dir.begins_with("user://") else settings_dir
		if relative_path.contains("/"):
			var parts = relative_path.split("/")
			var current = "user://"
			for part in parts:
				if part.is_empty():
					continue
				current = current.path_join(part)
				if not dir.dir_exists(current):
					dir.make_dir(current)
	
	var file = FileAccess.open(settings_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to save settings file.")
		return
	
	var json_string = JSON.stringify(settings, "\t")
	file.store_string(json_string)
	file.close()
	
	print("Settings saved to: ", settings_path)

func _merge_settings(loaded_settings: Dictionary):
	## Merge loaded settings with defaults (recursive)
	for key in loaded_settings:
		if settings.has(key):
			if typeof(settings[key]) == TYPE_DICTIONARY and typeof(loaded_settings[key]) == TYPE_DICTIONARY:
				_merge_dict(settings[key], loaded_settings[key])
			else:
				settings[key] = loaded_settings[key]
		else:
			settings[key] = loaded_settings[key]

func _merge_dict(target: Dictionary, source: Dictionary):
	## Recursive dictionary merge
	for key in source:
		if target.has(key):
			if typeof(target[key]) == TYPE_DICTIONARY and typeof(source[key]) == TYPE_DICTIONARY:
				_merge_dict(target[key], source[key])
			else:
				target[key] = source[key]
		else:
			target[key] = source[key]

func apply_settings():
	## Apply all settings to game
	_apply_audio_settings()
	_apply_display_settings()
	_apply_accessibility_settings()
	_apply_input_settings()

func _apply_audio_settings():
	## Apply audio settings
	var audio_settings = settings.get("audio", {})
	
	var music_volume = audio_settings.get("music_volume", 0.8)
	var ambient_volume = audio_settings.get("ambient_volume", 0.6)
	var sfx_volume = audio_settings.get("sfx_volume", 0.7)
	
	# Apply to audio buses
	var music_bus = AudioServer.get_bus_index("Music")
	var ambient_bus = AudioServer.get_bus_index("Ambient")
	var sfx_bus = AudioServer.get_bus_index("SFX")
	
	if music_bus >= 0:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
	if ambient_bus >= 0:
		AudioServer.set_bus_volume_db(ambient_bus, linear_to_db(ambient_volume))
	if sfx_bus >= 0:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))

func _apply_display_settings():
	## Apply display settings
	var display_settings = settings.get("display", {})
	
	var fullscreen = display_settings.get("fullscreen", false)
	var resolution = display_settings.get("resolution", {"width": 1280, "height": 720})
	
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(resolution.get("width", 1280), resolution.get("height", 720)))

func _apply_accessibility_settings():
	## Apply accessibility settings
	var acc_settings = settings.get("accessibility", {})
	
	var ui_scale = acc_settings.get("ui_scale", 1.0)
	var reduced_motion = acc_settings.get("reduced_motion", false)
	var colorblind_mode = acc_settings.get("colorblind_mode", "none")
	var high_contrast = acc_settings.get("high_contrast", false)
	var subtitles_enabled = acc_settings.get("subtitles_enabled", false)
	
	# Apply UI scale (affects all UI elements)
	# Would need to update all UI nodes - for now, emit signal
	settings_changed.emit("ui_scale", ui_scale)
	
	# Apply reduced motion
	if reduced_motion:
		# Disable camera shake, reduce particle intensity
		settings_changed.emit("reduced_motion", true)
	
	# Apply colorblind mode
	if colorblind_mode != "none":
		# Apply colorblind shader/filter
		settings_changed.emit("colorblind_mode", colorblind_mode)
	
	# Apply high contrast
	if high_contrast:
		# Apply high contrast shader/filter
		settings_changed.emit("high_contrast", true)
	
	# Apply subtitles
	if subtitles_enabled:
		# Enable subtitle system
		settings_changed.emit("subtitles_enabled", true)

func _apply_input_settings():
	## Apply input settings
	var input_settings = settings.get("input", {})
	
	var controller_enabled = input_settings.get("controller_enabled", false)
	
	# Enable/disable controller
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if not controller_enabled else Input.MOUSE_MODE_CAPTURED

func get_setting(key_path: String, default_value: Variant = null) -> Variant:
	## Get setting value by dot-separated path (e.g., "audio.music_volume")
	var keys = key_path.split(".")
	var current = settings
	
	for key in keys:
		if current.has(key):
			current = current[key]
		else:
			return default_value
	
	return current

func set_setting(key_path: String, value: Variant):
	## Set setting value by dot-separated path
	var keys = key_path.split(".")
	var current = settings
	
	for i in range(keys.size() - 1):
		var key = keys[i]
		if not current.has(key):
			current[key] = {}
		current = current[key]
	
	current[keys[-1]] = value
	settings_changed.emit(key_path, value)
	
	# Re-apply affected settings
	apply_settings()

func toggle_accessibility(option: String, enabled: bool):
	## Toggle accessibility option
	var acc_settings = settings.get("accessibility", {})
	
	match option:
		"reduced_motion":
			acc_settings["reduced_motion"] = enabled
			accessibility_toggled.emit(option, enabled)
		"high_contrast":
			acc_settings["high_contrast"] = enabled
			accessibility_toggled.emit(option, enabled)
		"subtitles_enabled":
			acc_settings["subtitles_enabled"] = enabled
			accessibility_toggled.emit(option, enabled)
		_:
			push_warning("Unknown accessibility option: ", option)
			return
	
	settings["accessibility"] = acc_settings
	apply_settings()
	save_settings()

func set_ui_scale(scale: float):
	## Set UI scale (1.0, 1.25, 1.5, 2.0)
	var valid_scales = [1.0, 1.25, 1.5, 2.0]
	if scale in valid_scales:
		set_setting("accessibility.ui_scale", scale)
	else:
		push_warning("Invalid UI scale: ", scale, ". Using 1.0.")
		set_setting("accessibility.ui_scale", 1.0)

func set_colorblind_mode(mode: String):
	## Set colorblind mode (none, protanopia, deuteranopia)
	var valid_modes = ["none", "protanopia", "deuteranopia"]
	if mode in valid_modes:
		set_setting("accessibility.colorblind_mode", mode)
	else:
		push_warning("Invalid colorblind mode: ", mode, ". Using none.")
		set_setting("accessibility.colorblind_mode", "none")

func _notification(what):
	## Save settings on exit
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_settings()
		get_tree().quit()

