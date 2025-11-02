extends Control
class_name TutorialOverlay

## Tutorial UI overlay with steampunk aesthetic

signal step_dismissed()
signal skip_requested()

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var message_label: RichTextLabel = $VBoxContainer/MessageLabel
@onready var journal_hint: Label = $VBoxContainer/JournalHint
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var skip_button: Button = $VBoxContainer/SkipButton
@onready var highlight_overlay: ColorRect = $HighlightOverlay

var current_step: int = -1

func _ready():
	set_visible(false)
	add_to_group("tutorial_ui")
	
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	if skip_button:
		skip_button.pressed.connect(_on_skip_pressed)

func show_step(title: String, message: String, step: int):
	## Show a tutorial step
	current_step = step
	
	if title_label:
		title_label.text = title
	if message_label:
		message_label.text = "[color=#D4AF37]" + message + "[/color]"  # Brass color
	if journal_hint:
		journal_hint.text = "Check your journal for more context."
	
	set_visible(true)
	
	# Fade in
	var tween = create_tween()
	modulate.a = 0.0
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func hide():
	## Hide tutorial overlay
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(set_visible.bind(false))

func highlight_element(path: String, message: String):
	## Highlight a UI element or world object
	if highlight_overlay:
		highlight_overlay.visible = true
		# Would position highlight overlay to frame the element
		pass

func _on_continue_pressed():
	## Continue to next step
	step_dismissed.emit()
	hide()

func _on_skip_pressed():
	## Skip tutorial
	skip_requested.emit()
	hide()

