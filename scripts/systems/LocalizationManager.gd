extends Node
# Note: Can't use class_name for autoload singletons in Godot
# class_name LocalizationManager

## Localization manager for translation dictionaries

signal language_changed(new_language: String)
signal translation_loaded()

var current_language: String = "en"
var translations: Dictionary = {}

func _ready():
	add_to_group("localization")
	
	# Load default language (English)
	load_language("en")

func load_language(language_code: String):
	## Load translation dictionary for specific language
	current_language = language_code
	
	var translation_path = "res://localization/" + language_code + ".json"
	
	if not FileAccess.file_exists(translation_path):
		push_warning("Translation file not found: ", translation_path, ". Using defaults.")
		_load_default_translations()
		return
	
	var file = FileAccess.open(translation_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open translation file. Using defaults.")
		_load_default_translations()
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_string) != OK:
		push_error("Failed to parse translation file. Using defaults.")
		_load_default_translations()
		return
	
	translations = json.get_data()
	translation_loaded.emit()
	language_changed.emit(language_code)
	
	print("Translations loaded for language: ", language_code)

func translate(key: String, default_text: String = "") -> String:
	## Translate key to current language (avoiding Object.tr() override)
	if translations.has(key):
		return translations[key]
	
	# Fallback to default text if provided
	if not default_text.is_empty():
		return default_text
	
	# Last resort: return key itself
	return key

func _load_default_translations():
	## Load default English translations as fallback
	translations = {
		"ui.menu.new_game": "New Game",
		"ui.menu.load_game": "Load Game",
		"ui.menu.settings": "Settings",
		"ui.menu.quit": "Quit",
		"npc.mara.greeting_hostile": "Your bloodline brings only ruin.",
		"npc.mara.greeting_neutral": "The earth remembers your family's choices.",
		"npc.mara.greeting_friendly": "Your family has honored the land. I respect that."
	}
	
	translation_loaded.emit()

func get_available_languages() -> Array[String]:
	## Get list of available language codes
	var languages: Array[String] = ["en"]  # English is always available
	
	# Check for additional language files
	var dir = DirAccess.open("res://localization/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json") and file_name != "strings.pot":
				var lang_code = file_name.get_basename()
				if not languages.has(lang_code):
					languages.append(lang_code)
			file_name = dir.get_next()
	
	return languages

