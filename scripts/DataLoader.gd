extends RefCounted
class_name DataLoader

## Utility class for loading JSON data files

static func load_json_file(path: String) -> Array:
	## Loads a JSON file and returns the parsed data as an Array or Dictionary
	if not ResourceLoader.exists(path):
		push_error("File not found: " + path)
		return []
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file: " + path)
		return []
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("JSON parse error at line " + str(json.get_error_line()) + ": " + json.get_error_message())
		return []
	
	var data = json.get_data()
	
	# Handle both Array and Dictionary returns
	if typeof(data) == TYPE_ARRAY:
		return data
	elif typeof(data) == TYPE_DICTIONARY:
		return [data]
	else:
		push_error("Unexpected data type in JSON file: " + path)
		return []

