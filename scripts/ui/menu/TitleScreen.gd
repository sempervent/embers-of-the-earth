extends Control
class_name TitleScreen

## Title screen with atmospheric intro

signal title_sequence_completed()

var is_active: bool = true

@onready var title_animation: AnimationPlayer = $TitleAnimation
@onready var subtitle_label: Label = $VBoxContainer/SubtitleLabel
@onready var press_any_key: Label = $VBoxContainer/PressAnyKeyLabel

func _ready():
	set_visible(true)
	add_to_group("title_screen")
	
	_start_title_sequence()

func _start_title_sequence():
	## Start title screen sequence
	# Fade in
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 2.0)
	
	# Play title animation
	if title_animation:
		await get_tree().create_timer(1.0).timeout
		title_animation.play("title_intro")
	
	# Show press any key
	if press_any_key:
		await get_tree().create_timer(3.0).timeout
		press_any_key.visible = true

func _input(event):
	if not is_active:
		return
	
	# Wait for any input to continue
	if event.is_pressed() and not event.is_echo():
		_continue_to_menu()

func _continue_to_menu():
	## Continue to main menu
	is_active = false
	
	# Fade out and transition
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/ui/menu/main_menu.tscn")
	)

