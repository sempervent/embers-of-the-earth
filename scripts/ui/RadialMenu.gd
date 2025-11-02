extends Control
class_name RadialMenu

## Radial action menu for tile interactions

signal action_selected(action_id: String)

var actions: Array[Dictionary] = []
var center_position: Vector2
var radius: float = 80.0
var is_visible: bool = false

var highlight_index: int = -1

func _ready():
	set_visible(false)
	set_mouse_filter(MOUSE_FILTER_IGNORE)

func _input(event):
	if not is_visible:
		return
	
	if event is InputEventMouseMotion:
		_update_highlight(event.position)
	elif event is InputEventMouseButton:
		if event.pressed:
			_select_action_at_position(event.position)

func show_menu(position: Vector2, available_actions: Array[Dictionary]):
	## Show radial menu at position
	center_position = position
	actions = available_actions
	is_visible = true
	set_visible(true)
	
	# Center menu
	global_position = position - Vector2(radius, radius)
	
	highlight_index = -1

func hide_menu():
	## Hide radial menu
	is_visible = false
	set_visible(false)
	highlight_index = -1

func _update_highlight(mouse_pos: Vector2):
	## Update highlighted action based on mouse position
	var local_pos = mouse_pos - center_position
	var distance = local_pos.length()
	
	if distance > radius:
		highlight_index = -1
		return
	
	# Calculate angle
	var angle = atan2(local_pos.y, local_pos.x)
	if angle < 0:
		angle += TAU
	
	# Map angle to action index
	var sector_size = TAU / actions.size()
	var index = int(angle / sector_size)
	
	highlight_index = index
	queue_redraw()

func _select_action_at_position(mouse_pos: Vector2):
	## Select action at mouse position
	var local_pos = mouse_pos - center_position
	var distance = local_pos.length()
	
	if distance > radius:
		hide_menu()
		return
	
	var angle = atan2(local_pos.y, local_pos.x)
	if angle < 0:
		angle += TAU
	
	var sector_size = TAU / actions.size()
	var index = int(angle / sector_size)
	
	if index >= 0 and index < actions.size():
		var action = actions[index]
		action_selected.emit(action.get("id", ""))
		hide_menu()

func _draw():
	## Draw radial menu
	if actions.is_empty():
		return
	
	var center = Vector2(radius, radius)
	var sector_size = TAU / actions.size()
	
	for i in range(actions.size()):
		var action = actions[i]
		var start_angle = i * sector_size - PI / 2
		var end_angle = (i + 1) * sector_size - PI / 2
		
		# Sector color
		var color = Color(0.2, 0.2, 0.2, 0.8)  # Dark background
		if i == highlight_index:
			color = Color(0.4, 0.3, 0.2, 0.9)  # Brass highlight
		
		# Draw sector (simplified - would use actual arc drawing)
		var points = PackedVector2Array()
		points.append(center)
		
		# Add arc points
		for j in range(8):
			var angle = lerp(start_angle, end_angle, j / 7.0)
			var point = center + Vector2(cos(angle), sin(angle)) * radius * 0.9
			points.append(point)
		
		draw_colored_polygon(points, color)
		
		# Draw action icon/text
		var mid_angle = (start_angle + end_angle) / 2.0
		var icon_pos = center + Vector2(cos(mid_angle), sin(mid_angle)) * radius * 0.6
		var action_name = action.get("name", "")
		draw_string(ThemeDB.fallback_font, icon_pos, action_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 12)

func get_actions_for_tile(tile: Tile) -> Array[Dictionary]:
	## Get available actions for a tile
	var available: Array[Dictionary] = []
	
	if not tile.is_tilled:
		available.append({"id": "till", "name": "Till", "icon": "till"})
	elif tile.current_crop == "":
		available.append({"id": "plant", "name": "Plant", "icon": "plant"})
	
	if tile.current_crop != "":
		if tile.is_ready_to_harvest():
			available.append({"id": "harvest", "name": "Harvest", "icon": "harvest"})
		else:
			available.append({"id": "inspect", "name": "Inspect", "icon": "inspect"})
	
	return available

