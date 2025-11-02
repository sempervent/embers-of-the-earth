extends Node
# Note: Can't use class_name for autoload singletons in Godot
# class_name GameManager

## Main game state manager for Embers of the Earth

signal day_advanced(day: int)
signal year_advanced(year: int)

static var instance: GameManager

static var current_day: int = 1
static var current_year: int = 1
static var current_season: String = "spring"

# Preload classes to avoid type resolution issues
const PlayerClass = preload("res://scripts/Player.gd")
const FarmGridClass = preload("res://scripts/FarmGrid.gd")

var player: Node  # Will be Player type, using Node to avoid type resolution issues
var farm_grid: Node2D  # Will be FarmGrid type
var is_paused: bool = false

const DAYS_PER_YEAR = 120
const SEASONS = ["spring", "summer", "autumn", "winter"]
const DAYS_PER_SEASON = DAYS_PER_YEAR / 4

func _ready():
	if instance == null:
		instance = self
	else:
		queue_free()
		return
	
	# Initialize player (will be customized in character creation)
	var player_instance = PlayerClass.new()
	player = player_instance
	add_child(player_instance)
	
	# Start day advancement timer (advance day every 60 seconds for testing)
	# In real gameplay, this would be controlled by player actions
	# For now, add a timer that advances days periodically
	start_day_timer()
	
	# Initialize with old farmer setup (dies after year 1)
	_initialize_old_farmer_setup()

func advance_day():
	## Advances the game by one day
	if is_paused:
		return
	
	current_day += 1
	
	# Check for season change
	var season_index = int((current_day - 1) / DAYS_PER_SEASON) % SEASONS.size()
	current_season = SEASONS[season_index]
	
	# Check for year change
	if (current_day - 1) % DAYS_PER_YEAR == 0 and current_day > 1:
		advance_year()
	
	# Advance crop growth
	if farm_grid:
		farm_grid.advance_all_crops()
	
	day_advanced.emit(current_day)

func advance_year():
	## Advances the game by one year
	current_year += 1
	
	# Age player
	var died = player.age_up()
	if died:
		_handle_player_death()
	
	year_advanced.emit(current_year)

func _handle_player_death():
	## Handles player death and succession
	print("Player died at age " + str(player.age))
	print("Transferring control to " + player.name)

func get_date_string() -> String:
	## Returns a formatted date string
	return "Year " + str(current_year) + ", Day " + str(current_day) + " (" + current_season + ")"

func pause_game():
	is_paused = true

func resume_game():
	is_paused = false

func save_game(path: String = "user://savegame.json") -> bool:
	## Saves the game state to a file
	var save_data = {
		"current_day": current_day,
		"current_year": current_year,
		"current_season": current_season,
		"player": player.get_player_data() if player else {},
		"farm": farm_grid.get_farm_data() if farm_grid else {}
	}
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file: " + path)
		return false
	
	file.store_string(JSON.stringify(save_data))
	file.close()
	
	return true

func load_game(path: String = "user://savegame.json") -> bool:
	## Loads the game state from a file
	if not FileAccess.file_exists(path):
		push_error("Save file not found: " + path)
		return false
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file: " + path)
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("JSON parse error: " + json.get_error_message())
		return false
	
	var save_data = json.get_data()
	
	current_day = save_data.get("current_day", 1)
	current_year = save_data.get("current_year", 1)
	current_season = save_data.get("current_season", "spring")
	
	if player:
		player.load_player_data(save_data.get("player", {}))
	
	if farm_grid:
		farm_grid.load_farm_data(save_data.get("farm", {}))
	
	return true

func start_day_timer():
	## Start automatic day advancement timer
	# Advance day every 60 seconds (for testing - in real gameplay this is manual)
	var timer = Timer.new()
	timer.wait_time = 60.0  # 60 seconds = 1 game day
	timer.timeout.connect(advance_day)
	timer.autostart = true
	add_child(timer)
	timer.name = "DayTimer"

func _initialize_old_farmer_setup():
	## Initialize game with old farmer who dies after first year
	# Set player to old age (will die after first year)
	if player:
		player.character_name = "Elias Coalroot"
		player.name = "Elias Coalroot"
		player.age = 68  # Old age - high death chance
		player.traits = ["stubborn", "mechanically_gifted"]  # Default traits
		
		# Set up farm grid with some existing crops (inherited farm)
		# This will be initialized when farm scene loads

