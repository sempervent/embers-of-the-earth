extends Node
class_name AtmosphereManager

## Central manager for all atmosphere systems
## Coordinates music, sound, weather, visual effects, and journal

const ProceduralMusicClass = preload("res://scripts/audio/ProceduralMusic.gd")
const AmbientSoundManagerClass = preload("res://scripts/audio/AmbientSoundManager.gd")
const WeatherSystemClass = preload("res://scripts/weather/WeatherSystem.gd")
const VisualEffectsClass = preload("res://scripts/visual/VisualEffects.gd")
const JournalSystemClass = preload("res://scripts/atmosphere/JournalSystem.gd")

signal atmosphere_initialized

var procedural_music: Node  # Will be ProceduralMusic
var ambient_sound: Node  # Will be AmbientSoundManager
var weather_system: Node  # Will be WeatherSystem
var visual_effects: Node  # Will be VisualEffects
var journal_system: Node  # Will be JournalSystem

var game_manager: Node  # Will be GameManager

func _ready():
	add_to_group("atmosphere")  # Allow finding via group
	_initialize_systems()
	_connect_signals()

func _initialize_systems():
	## Initialize all atmosphere systems
	# Create systems
	procedural_music = ProceduralMusicClass.new()
	procedural_music.name = "ProceduralMusic"
	add_child(procedural_music)
	
	ambient_sound = AmbientSoundManagerClass.new()
	ambient_sound.name = "AmbientSound"
	add_child(ambient_sound)
	
	weather_system = WeatherSystemClass.new()
	weather_system.name = "WeatherSystem"
	add_child(weather_system)
	
	visual_effects = VisualEffectsClass.new()
	visual_effects.name = "VisualEffects"
	add_child(visual_effects)
	
	journal_system = JournalSystemClass.new()
	journal_system.name = "JournalSystem"
	add_child(journal_system)
	
	# Connect cross-system references
	weather_system.ambient_sound = ambient_sound
	weather_system.procedural_music = procedural_music
	weather_system.visual_effects = visual_effects
	
	atmosphere_initialized.emit()

func _connect_signals():
	## Connect signals between systems and game manager
	game_manager = GameManager.instance
	if not game_manager:
		push_error("GameManager not found!")
		return
	
	# Connect game manager signals
	game_manager.day_advanced.connect(_on_day_advanced)
	game_manager.year_advanced.connect(_on_year_advanced)
	
	if game_manager.player:
		game_manager.player.player_aged.connect(_on_player_aged)
		game_manager.player.player_died.connect(_on_player_died)
	
	# Connect weather signals
	weather_system.weather_changed.connect(_on_weather_changed)
	
	# Connect journal signals
	journal_system.journal_entry_added.connect(_on_journal_entry_added)

func _on_day_advanced(day: int):
	## Handle day advancement
	# Update time of day for systems
	var time_of_day = _get_time_of_day(day)
	
	procedural_music.update_condition("time_of_day", time_of_day)
	ambient_sound.update_condition("time_of_day", time_of_day)
	visual_effects.set_time_of_day_modulation(time_of_day)

func _on_year_advanced(year: int):
	## Handle year advancement
	if journal_system:
		journal_system.set_year(year)
	
	# Add yearly journal entry
	if game_manager and game_manager.player:
		var crop_count = _count_crops()
		journal_system.add_yearly_summary(
			game_manager.player.name,
			crop_count,
			game_manager.player.age
		)

func _on_player_aged(new_age: int):
	## Handle player aging
	procedural_music.update_condition("player_age", new_age)
	
	# Slow down music as player ages
	if new_age > 60:
		procedural_music.update_condition("player_dying", true)

func _on_player_died(successor: Dictionary):
	## Handle player death
	# Add death journal entry
	if game_manager and game_manager.player:
		journal_system.add_death_entry(
			game_manager.player.name,
			game_manager.player.age,
			successor.get("name", "Unknown"),
			"age"
		)
	
	# Trigger death music
	procedural_music.update_condition("player_dying", true)
	
	# Fade out ambient sounds
	ambient_sound.fade_out_all(3.0)

func _on_weather_changed(weather_type: String):
	## Handle weather changes
	# Add weather journal entry
	if game_manager and game_manager.player:
		journal_system.add_weather_entry(
			weather_type,
			game_manager.player.name
		)

func _on_journal_entry_added(entry: Dictionary):
	## Handle new journal entry
	print("Journal entry: ", entry.get("text", ""))

func _get_time_of_day(day: int) -> String:
	## Determine time of day based on day cycle
	# Simplified: cycle through times
	var hour = (day % 24)
	if hour < 6:
		return "night"
	elif hour < 12:
		return "morning"
	elif hour < 18:
		return "noon"
	else:
		return "evening"

func _count_crops() -> int:
	## Count total crops on farm
	var count = 0
	if game_manager and game_manager.farm_grid:
		for tile in game_manager.farm_grid.tiles.values():
			if tile.current_crop != "":
				count += 1
	return count

func trigger_machine_event():
	## Trigger a machine awakening event
	procedural_music.update_condition("machine_awakening", true)
	ambient_sound.play_event_sound("machine_awakening")
	journal_system.add_machine_event_entry(
		game_manager.player.name if game_manager and game_manager.player else "Unknown"
	)

func trigger_crop_growth_event():
	## Trigger when crops are growing
	procedural_music.update_condition("crops_growing", true)
	procedural_music.update_condition("entropy_level", 0.5)

