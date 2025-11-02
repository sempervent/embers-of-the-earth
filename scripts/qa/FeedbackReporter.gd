extends Control
class_name FeedbackReporter

## In-game feedback reporter with screenshot capability

signal feedback_sent()

@onready var feedback_text: TextEdit = $VBoxContainer/FeedbackText
@onready var screenshot_button: Button = $VBoxContainer/Actions/ScreenshotButton
@onready var send_button: Button = $VBoxContainer/Actions/SendButton
@onready var cancel_button: Button = $VBoxContainer/Actions/CancelButton

var screenshot_path: String = ""

func _ready():
	set_visible(false)
	add_to_group("feedback_reporter")

func show_feedback_ui():
	## Show feedback UI (ESC menu)
	set_visible(true)
	
	if feedback_text:
		feedback_text.text = ""
	
	screenshot_path = ""

func hide_feedback_ui():
	## Hide feedback UI
	set_visible(false)

func _on_screenshot_pressed():
	## Take screenshot for feedback
	var screenshot = get_viewport().get_texture().get_image()
	var timestamp = Time.get_unix_time_from_system()
	var filename = "user://feedback_screenshot_" + str(timestamp) + ".png"
	
	screenshot.save_png(filename)
	screenshot_path = filename
	
	if send_button:
		send_button.text = "Send Feedback (with screenshot)"

func _on_send_pressed():
	## Send feedback
	var feedback = feedback_text.text if feedback_text else ""
	
	if feedback.is_empty():
		push_warning("Please enter feedback")
		return
	
	_save_feedback(feedback)
	feedback_sent.emit()
	hide_feedback_ui()

func _on_cancel_pressed():
	## Cancel feedback
	hide_feedback_ui()

func _save_feedback(feedback: String):
	## Save feedback to file
	var timestamp = Time.get_unix_time_from_system()
	var feedback_data = {
		"timestamp": timestamp,
		"feedback": feedback,
		"screenshot": screenshot_path,
		"game_state": _get_current_state()
	}
	
	var filename = "user://feedback_" + str(timestamp) + ".json"
	var file = FileAccess.open(filename, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(feedback_data))
		file.close()
	
	print("Feedback saved to: " + filename)

func _get_current_state() -> Dictionary:
	## Get current game state for feedback
	var state = {
		"year": GameManager.current_year,
		"day": GameManager.current_day,
		"generation": 1
	}
	
	var game_manager = GameManager.instance
	if game_manager and game_manager.player:
		state["player_name"] = game_manager.player.name
		state["player_age"] = game_manager.player.age
	
	return state

