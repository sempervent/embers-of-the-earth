extends Node
class_name InputMapper

## Rebindable input system with persistence

signal input_rebound(action: String, event: InputEvent)

var action_mappings: Dictionary = {
	"move_up": [],
	"move_down": [],
	"move_left": [],
	"move_right": [],
	"interact": [],
	"travel_menu": [],
	"inventory": [],
	"journal": [],
	"radial_menu": []
}

var default_mappings: Dictionary = {}

func _ready():
	_load_default_mappings()
	_load_input_mappings()

func _load_default_mappings():
	## Set default input mappings
	default_mappings = {
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"interact": [KEY_E],
		"travel_menu": [KEY_T],
		"inventory": [KEY_I],
		"journal": [KEY_J],
		"radial_menu": [KEY_E]  # Hold
	}
	
	# Apply defaults if not already set
	for action in default_mappings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		
		for keycode in default_mappings[action]:
			var event = InputEventKey.new()
			event.keycode = keycode
			if not InputMap.action_has_event(action, event):
				InputMap.action_add_event(action, event)

func _load_input_mappings():
	## Load saved input mappings
	if not FileAccess.file_exists("user://input_mappings.json"):
		return
	
	var file = FileAccess.open("user://input_mappings.json", FileAccess.READ)
	if file == null:
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Input mappings parse error")
		return
	
	var mappings = json.get_data()
	
	# Apply loaded mappings
	for action in mappings:
		if InputMap.has_action(action):
			# Clear existing events
			var events = InputMap.action_get_events(action)
			for event in events:
				InputMap.action_erase_event(action, event)
			
			# Add loaded events
			var event_list = mappings[action]
			for keycode in event_list:
				var event = InputEventKey.new()
				event.keycode = keycode
				InputMap.action_add_event(action, event)

func rebind_action(action: String, new_event: InputEvent) -> bool:
	## Rebind an action to a new input event
	if not InputMap.has_action(action):
		push_error("Action not found: " + action)
		return false
	
	# Remove old events
	var old_events = InputMap.action_get_events(action)
	for event in old_events:
		InputMap.action_erase_event(action, event)
	
	# Add new event
	InputMap.action_add_event(action, new_event)
	
	# Save
	_save_input_mappings()
	
	input_rebound.emit(action, new_event)
	return true

func rebind_action_by_keycode(action: String, keycode: int) -> bool:
	## Rebind action to a keycode
	var event = InputEventKey.new()
	event.keycode = keycode
	return rebind_action(action, event)

func reset_to_defaults():
	## Reset all mappings to defaults
	for action in default_mappings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		
		# Clear existing
		var events = InputMap.action_get_events(action)
		for event in events:
			InputMap.action_erase_event(action, event)
		
		# Apply defaults
		for keycode in default_mappings[action]:
			var event = InputEventKey.new()
			event.keycode = keycode
			InputMap.action_add_event(action, event)
	
	_save_input_mappings()

func _save_input_mappings():
	## Save input mappings to file
	var mappings = {}
	
	for action in default_mappings:
		if InputMap.has_action(action):
			var events = InputMap.action_get_events(action)
			var keycodes = []
			
			for event in events:
				if event is InputEventKey:
					keycodes.append(event.keycode)
			
			mappings[action] = keycodes
	
	var file = FileAccess.open("user://input_mappings.json", FileAccess.WRITE)
	if file == null:
		push_error("Failed to save input mappings")
		return
	
	file.store_string(JSON.stringify(mappings))
	file.close()

func get_action_keycode(action: String) -> int:
	## Get primary keycode for an action
	if not InputMap.has_action(action):
		return KEY_NONE
	
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			return event.keycode
	
	return KEY_NONE

func get_action_display_string(action: String) -> String:
	## Get display string for action (e.g., "E", "WASD")
	var keycode = get_action_keycode(action)
	if keycode == KEY_NONE:
		return "?"
	
	return OS.get_keycode_string(keycode)

