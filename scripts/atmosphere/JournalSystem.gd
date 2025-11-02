extends Node
class_name JournalSystem

## Procedural journal system that generates entries based on gameplay
## Creates family history and environmental storytelling

signal journal_entry_added(entry: Dictionary)
signal generation_changed(generation: int)

var journal_entries: Array[Dictionary] = []
var current_generation: int = 1
var current_year: int = 1

# Templates for procedural generation
var entry_templates: Dictionary = {
	"first_harvest": [
		"The first {crop} of this generation. The soil whispers {mood}. —{name}",
		"Harvested {crop} today. The earth remembers {last_crop}. —{name}",
		"Today's harvest: {crop}. The land feels {mood}. —{name}"
	],
	"marriage": [
		"Married into the {faction} today. A new chapter begins. —{name}",
		"Joined with {spouse_name} from {faction}. Our bloodlines entwine. —{name}",
		"Wedding day. The {faction} brought {offering}. —{name}"
	],
	"death": [
		"{name} passed today, age {age}. The farm mourns. —{successor}",
		"Father/Mother is gone. {cause}. I must continue. —{successor}",
		"End of an era. {name} ({age}) leaves the farm to {successor}. —{successor}"
	],
	"weather": [
		"The {weather} came today. Crops {status}. —{name}",
		"Terrible {weather}. Lost {lost_crops} crops. —{name}",
		"The {weather} passed. The farm endures. —{name}"
	],
	"soil_memory": [
		"The soil at ({x}, {y}) remembers {years} years of {crop}. It feels {mood}. —{name}",
		"Tilled old ground. The earth whispers of {last_crop}. —{name}",
		"Soil memory: {years} years. The land grows {mood}. —{name}"
	],
	"machine_event": [
		"The machine beneath stirred today. The pipes hummed. —{name}",
		"Steam rose from the old vents. Something moves below. —{name}",
		"The gears beneath ground turned. The farm trembles. —{name}"
	],
	"first_child": [
		"{child_name} born today. Our bloodline continues. —{name}",
		"New life on the farm. {child_name} takes their first breath. —{name}",
		"Welcome, {child_name}. May you tend the earth well. —{name}"
	],
	"yearly_summary": [
		"Year {year} complete. Harvested {crop_count} crops. Age {age}. —{name}",
		"End of year {year}. The farm grows. I age. —{name}",
		"Year {year} done. {summary}. —{name}"
	]
}

func _ready():
	# Initialize with first entry
	add_entry("first_entry", {
		"name": "Elias Coalroot",
		"year": 1,
		"generation": 1,
		"text": "The farm begins. The earth waits. —Elias Coalroot"
	})

func add_entry(entry_type: String, data: Dictionary):
	## Add a new journal entry procedurally
	var template_list = entry_templates.get(entry_type, [])
	if template_list.is_empty():
		push_warning("No template found for entry type: " + entry_type)
		return
	
	# Select random template
	var template = template_list[randi() % template_list.size()]
	
	# Fill in template variables
	var entry_text = template.format(data)
	
	# Create entry
	var entry: Dictionary = {
		"text": entry_text,
		"type": entry_type,
		"year": data.get("year", current_year),
		"generation": data.get("generation", current_generation),
		"player_name": data.get("name", "Unknown"),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	journal_entries.append(entry)
	journal_entry_added.emit(entry)

func add_first_harvest_entry(crop_name: String, player_name: String, tile_mood: String, last_crop: String = ""):
	## Add entry for first harvest
	add_entry("first_harvest", {
		"crop": crop_name,
		"mood": tile_mood,
		"last_crop": last_crop if last_crop != "" else "nothing",
		"name": player_name,
		"year": current_year,
		"generation": current_generation
	})

func add_marriage_entry(spouse_name: String, faction_name: String, player_name: String, offering: String = ""):
	## Add entry for marriage
	add_entry("marriage", {
		"spouse_name": spouse_name,
		"faction": faction_name,
		"offering": offering,
		"name": player_name,
		"year": current_year,
		"generation": current_generation
	})

func add_death_entry(dead_name: String, age: int, successor_name: String, cause: String = "age"):
	## Add entry for player death
	add_entry("death", {
		"name": dead_name,
		"age": age,
		"successor": successor_name,
		"cause": cause,
		"year": current_year,
		"generation": current_generation
	})

func add_weather_entry(weather_type: String, player_name: String, crop_status: String = "survived", lost_crops: int = 0):
	## Add entry for weather events
	add_entry("weather", {
		"weather": weather_type,
		"status": crop_status,
		"lost_crops": str(lost_crops) if lost_crops > 0 else "none",
		"name": player_name,
		"year": current_year,
		"generation": current_generation
	})

func add_soil_memory_entry(x: int, y: int, years_used: int, crop_type: String, mood: String, player_name: String):
	## Add entry about soil memory
	add_entry("soil_memory", {
		"x": str(x),
		"y": str(y),
		"years": str(years_used),
		"crop": crop_type,
		"mood": mood,
		"name": player_name,
		"year": current_year,
		"generation": current_generation
	})

func add_machine_event_entry(player_name: String):
	## Add entry about machine events
	add_entry("machine_event", {
		"name": player_name,
		"year": current_year,
		"generation": current_generation
	})

func add_first_child_entry(child_name: String, player_name: String):
	## Add entry for first child birth
	add_entry("first_child", {
		"child_name": child_name,
		"name": player_name,
		"year": current_year,
		"generation": current_generation
	})

func add_yearly_summary(player_name: String, crop_count: int, age: int, summary: String = ""):
	## Add yearly summary entry
	add_entry("yearly_summary", {
		"year": str(current_year),
		"crop_count": str(crop_count),
		"age": str(age),
		"summary": summary if summary != "" else "Another year passes.",
		"name": player_name
	})

func advance_generation(new_generation: int):
	## Advance to next generation
	current_generation = new_generation
	generation_changed.emit(new_generation)
	
	add_entry("generation_change", {
		"generation": str(new_generation),
		"year": current_year,
		"text": "Generation " + str(new_generation) + " begins. The bloodline continues."
	})

func set_year(year: int):
	## Set current year
	current_year = year

func get_journal_entries() -> Array[Dictionary]:
	## Get all journal entries
	return journal_entries.duplicate()

func get_entries_by_generation(generation: int) -> Array[Dictionary]:
	## Get entries for a specific generation
	var filtered: Array[Dictionary] = []
	for entry in journal_entries:
		if entry.get("generation", 0) == generation:
			filtered.append(entry)
	return filtered

func get_entries_by_year(year: int) -> Array[Dictionary]:
	## Get entries for a specific year
	var filtered: Array[Dictionary] = []
	for entry in journal_entries:
		if entry.get("year", 0) == year:
			filtered.append(entry)
	return filtered

func get_recent_entries(count: int = 10) -> Array[Dictionary]:
	## Get most recent entries
	var entries = journal_entries.duplicate()
	entries.reverse()
	return entries.slice(0, min(count, entries.size()))

