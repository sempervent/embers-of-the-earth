extends Control
class_name PrologueSequence

## Prologue sequence with First Winter Letter

signal prologue_completed()

var prologue_data: Dictionary = {}
var current_text_index: int = 0
var is_active: bool = false

@onready var letter_display: RichTextLabel = $LetterPanel/LetterText
@onready var continue_button: Button = $LetterPanel/ContinueButton
@onready var skip_button: Button = $LetterPanel/SkipButton
@onready var candle_animation: AnimationPlayer = $CandleAnimation

func _ready():
	_load_prologue()
	set_visible(true)
	# Auto-start prologue when scene loads
	start_prologue()

func start_prologue():
	## Start prologue sequence
	_load_prologue()
	is_active = true
	current_text_index = 0
	set_visible(true)
	
	# Start candle animation
	if candle_animation:
		candle_animation.play("flicker")
	
	_display_next_text()

const DataLoader = preload("res://scripts/DataLoader.gd")

func _load_prologue():
	## Load prologue data
	prologue_data = DataLoader.load_json_file("res://data/prologue/first_winter_letter.json")
	
	# If it's an array, take first element
	if typeof(prologue_data) == TYPE_ARRAY:
		if not prologue_data.is_empty():
			prologue_data = prologue_data[0]

func _display_next_text():
	## Display next text segment
	var text_array = prologue_data.get("text", [])
	
	if current_text_index >= text_array.size():
		_complete_prologue()
		return
	
	var text = text_array[current_text_index]
	
	# Typewriter effect
	_typewriter_text(text)
	
	current_text_index += 1
	
	# Auto-advance after delay
	var speed = prologue_data.get("narration_speed", 2.0)
	get_tree().create_timer(speed).timeout.connect(_display_next_text)

func _typewriter_text(text: String):
	## Typewriter effect for text
	if not letter_display:
		return
	
	letter_display.text = ""
	var full_text = text
	var char_index = 0
	
	# Type out character by character
	var timer = get_tree().create_timer(0.05)
	timer.timeout.connect(func():
		if char_index < full_text.length():
			letter_display.text += full_text[char_index]
			char_index += 1
			timer.timeout = 0.05
		else:
			timer.queue_free()
	)

func _on_continue_pressed():
	## Continue to next text
	_display_next_text()

func _on_skip_pressed():
	## Skip prologue
	_complete_prologue()

func _complete_prologue():
	## Complete prologue sequence
	is_active = false
	
	# Fade out
	var fade_duration = prologue_data.get("fade_out_duration", 3.0)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(_transition_to_game)

func _transition_to_game():
	## Transition to main game
	set_visible(false)
	prologue_completed.emit()
	
	# Load farm scene
	var next_scene = prologue_data.get("next_scene", "farm")
	get_tree().change_scene_to_file("res://scenes/" + next_scene + ".tscn")

