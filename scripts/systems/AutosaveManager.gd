extends Node
class_name AutosaveManager

## Rolling autosave system with crash protection

signal autosave_created(slot: int)
signal autosave_failed(reason: String)

const AUTOSAVE_SLOTS = 3
const AUTOSAVE_INTERVAL = 300.0  # 5 minutes

var autosave_timer: float = 0.0
var current_slot: int = 0

var game_manager: GameManager

func _ready():
	game_manager = GameManager.instance
	
	# Start autosave timer
	autosave_timer = AUTOSAVE_INTERVAL

func _process(delta):
	if not game_manager:
		return
	
	autosave_timer -= delta
	
	if autosave_timer <= 0.0:
		create_autosave()
		autosave_timer = AUTOSAVE_INTERVAL

func create_autosave():
	## Create an autosave
	var save_data = SaveSchema.serialize_game_state()
	
	# Add autosave metadata
	save_data["autosave"] = true
	save_data["autosave_timestamp"] = Time.get_unix_time_from_system()
	
	# Write to temporary file first
	var temp_path = "user://autosave_temp_" + str(current_slot) + ".json"
	var file = FileAccess.open(temp_path, FileAccess.WRITE)
	
	if file == null:
		autosave_failed.emit("Failed to open temp file")
		return
	
	var json_string = JSON.stringify(save_data)
	
	# Calculate CRC
	var crc = _calculate_crc(json_string)
	save_data["crc"] = crc
	
	# Write again with CRC
	file.seek(0)
	file.store_string(JSON.stringify(save_data))
	file.close()
	
	# Atomic rename
	var final_path = "user://autosave_" + str(current_slot) + ".json"
	var dir = DirAccess.open("user://")
	if dir:
		# Remove old save if exists
		if dir.file_exists(final_path):
			dir.remove(final_path)
		dir.rename(temp_path.trim_prefix("user://"), final_path.trim_prefix("user://"))
	
	# Advance to next slot
	current_slot = (current_slot + 1) % AUTOSAVE_SLOTS
	
	autosave_created.emit(current_slot)

func load_autosave(slot: int) -> bool:
	## Load an autosave slot
	var path = "user://autosave_" + str(slot) + ".json"
	
	if not FileAccess.file_exists(path):
		return false
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	# Verify CRC
	var saved_crc = _extract_crc(json_string)
	var calculated_crc = _calculate_crc(json_string)
	
	if saved_crc != calculated_crc:
		autosave_failed.emit("CRC mismatch - file may be corrupted")
		return false
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		autosave_failed.emit("JSON parse error")
		return false
	
	var save_data = json.get_data()
	return SaveSchema.deserialize_game_state(save_data)

func get_autosave_info(slot: int) -> Dictionary:
	## Get info about an autosave slot
	var path = "user://autosave_" + str(slot) + ".json"
	
	if not FileAccess.file_exists(path):
		return {}
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_string) != OK:
		return {}
	
	var data = json.get_data()
	return {
		"exists": true,
		"timestamp": data.get("autosave_timestamp", 0),
		"day": data.get("game_state", {}).get("current_day", 0),
		"year": data.get("game_state", {}).get("current_year", 0)
	}

func _calculate_crc(data: String) -> int:
	## Calculate simple CRC for save file
	var crc = 0
	for i in range(data.length()):
		crc = (crc << 1) ^ data.unicode_at(i)
	return crc & 0xFFFFFFFF

func _extract_crc(json_string: String) -> int:
	## Extract CRC from JSON string
	var json = JSON.new()
	if json.parse(json_string) != OK:
		return 0
	
	var data = json.get_data()
	return data.get("crc", 0)

