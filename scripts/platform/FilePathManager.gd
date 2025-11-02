extends RefCounted
class_name FilePathManager

## Platform-aware file path manager for saves, settings, and data

static func get_user_data_dir() -> String:
	## Get platform-specific user data directory
	var os_name = OS.get_name()
	
	match os_name:
		"Windows":
			return OS.get_user_data_dir().path_join("EmbersOfTheEarth")
		"macOS":
			return OS.get_user_data_dir().path_join("EmbersOfTheEarth")
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			return OS.get_user_data_dir().path_join("EmbersOfTheEarth")
		_:
			# Fallback to user://
			return "user://"

static func get_save_directory() -> String:
	## Get save file directory
	var base_dir = get_user_data_dir()
	return base_dir.path_join("saves")

static func get_settings_directory() -> String:
	## Get settings directory
	var base_dir = get_user_data_dir()
	return base_dir.path_join("config")

static func get_log_directory() -> String:
	## Get log file directory
	var base_dir = get_user_data_dir()
	return base_dir.path_join("logs")

static func get_save_path(slot: int = -1) -> String:
	## Get save file path for specific slot
	var save_dir = get_save_directory()
	_ensure_directory_exists(save_dir)
	
	if slot == -1:
		return save_dir.path_join("save_auto.json")
	else:
		return save_dir.path_join("save_" + str(slot) + ".json")

static func get_autosave_path(index: int) -> String:
	## Get autosave file path for specific index (0-2)
	var save_dir = get_save_directory()
	_ensure_directory_exists(save_dir)
	return save_dir.path_join("autosave_" + str(index) + ".json")

static func get_settings_path() -> String:
	## Get settings file path
	var settings_dir = get_settings_directory()
	_ensure_directory_exists(settings_dir)
	return settings_dir.path_join("settings.json")

static func get_log_path(filename: String = "game.log") -> String:
	## Get log file path
	var log_dir = get_log_directory()
	_ensure_directory_exists(log_dir)
	return log_dir.path_join(filename)

static func _ensure_directory_exists(path: String):
	## Ensure directory exists, creating if necessary
	if path.begins_with("user://"):
		# Use user:// directory (Godot handles creation)
		var dir = DirAccess.open("user://")
		if dir:
			# Create subdirectories if needed
			var relative_path = path.replace("user://", "")
			if relative_path.contains("/"):
				var parts = relative_path.split("/")
				var current = "user://"
				for part in parts:
					current = current.path_join(part)
					if not dir.dir_exists(current):
						dir.make_dir(current)
	else:
		# Use absolute path
		var dir = DirAccess.open(path.get_base_dir())
		if dir == null:
			# Parent doesn't exist, try to create it
			var parent = path.get_base_dir()
			if not DirAccess.dir_exists_absolute(parent):
				_ensure_directory_exists(parent)
			
			dir = DirAccess.open(path.get_base_dir())
		
		if dir:
			var dir_name = path.get_file()
			if not dir.dir_exists(dir_name):
				dir.make_dir(dir_name)

static func get_feedback_directory() -> String:
	## Get feedback file directory
	var base_dir = get_user_data_dir()
	return base_dir.path_join("feedback")

static func get_feedback_path() -> String:
	## Get feedback file path
	var feedback_dir = get_feedback_directory()
	_ensure_directory_exists(feedback_dir)
	var timestamp = Time.get_unix_time_from_system()
	return feedback_dir.path_join("feedback_" + str(timestamp) + ".json")

