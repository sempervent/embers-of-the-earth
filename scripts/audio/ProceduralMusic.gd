extends Node
class_name ProceduralMusic

## Procedural Western/Steampunk music system
## Uses Markov chains for chord progressions and dynamic layering

signal music_layer_changed(layer_name: String, active: bool)
signal music_condition_changed(condition: String)

# Western minor pentatonic scale: C D Eb G Ab
const PENTATONIC_SCALE = [0, 2, 3, 7, 10]  # Semitone offsets from root
const DORIAN_SCALE = [0, 2, 3, 5, 7, 9, 10]  # Dorian mode offsets

# Markov chain state for chord progressions
var current_state: String = "calm"
var chord_progression: Array[int] = []
var current_chord_index: int = 0

# Instrument layers
var active_layers: Dictionary = {
	"banjo": false,
	"harmonica": false,
	"percussion": false,
	"violin": false,
	"steel_guitar": false,
	"harmonium": false,
	"brass": false
}

# Audio players for each layer
var audio_players: Dictionary = {}
var audio_streams: Dictionary = {}

# Music conditions that affect layering
var conditions: Dictionary = {
	"time_of_day": "morning",  # morning, noon, evening, night
	"weather": "clear",  # clear, dust_storm, ash_fall, static_storm
	"player_age": 43,
	"player_dying": false,
	"entropy_level": 0.0,  # 0.0 = calm, 1.0 = chaos
	"crops_growing": false,
	"machine_awakening": false
}

# Chord progression Markov chains (from_state -> [(to_state, probability), ...])
var chord_markov: Dictionary = {
	"i": [["iv", 0.4], ["v", 0.3], ["i", 0.2], ["vi", 0.1]],  # Minor tonic
	"iv": [["i", 0.5], ["v", 0.3], ["vi", 0.2]],  # Subdominant
	"v": [["i", 0.6], ["vi", 0.3], ["iv", 0.1]],  # Dominant
	"vi": [["iv", 0.4], ["v", 0.3], ["i", 0.3]],  # Relative major
}

var root_note: int = 48  # C3 MIDI note
var tempo: float = 60.0  # BPM

func _ready():
	_initialize_audio_players()
	_update_music_for_conditions()

func _initialize_audio_players():
	## Initialize AudioStreamPlayer nodes for each instrument layer
	for layer_name in active_layers.keys():
		var player = AudioStreamPlayer.new()
		player.name = layer_name.capitalize()
		add_child(player)
		audio_players[layer_name] = player
		# Note: Actual audio streams would be loaded from assets
		# audio_streams[layer_name] = load("res://assets/sounds/music/" + layer_name + ".ogg")

func update_condition(condition_name: String, value):
	## Update a music condition and trigger music changes
	if conditions.has(condition_name):
		conditions[condition_name] = value
		_update_music_for_conditions()
		music_condition_changed.emit(condition_name)

func _update_music_for_conditions():
	## Update active layers and music state based on conditions
	var old_layers = active_layers.duplicate()
	
	# Reset all layers
	for layer in active_layers:
		active_layers[layer] = false
	
	# Morning calm: sparse banjo + soft wind + ticking valves
	if conditions.time_of_day == "morning" and conditions.weather == "clear":
		active_layers["banjo"] = true
		active_layers["percussion"] = true
		state = "calm"
	
	# Dust storm: droning harmonium + low brass + metallic scraping
	elif conditions.weather == "dust_storm":
		active_layers["harmonium"] = true
		active_layers["brass"] = true
		active_layers["percussion"] = true
		state = "tense"
	
	# Player aging: cracked music box, slowed & detuned
	elif conditions.player_age > 60 or conditions.player_dying:
		active_layers["harmonium"] = true  # Music box-like
		tempo = 60.0 * (1.0 - (conditions.player_age - 60) / 40.0)  # Slow down with age
		state = "melancholic"
	
	# Death of farmer: wind howling over empty strings, heartbeat stops
	elif conditions.player_dying:
		active_layers["violin"] = true
		tempo = 30.0  # Very slow
		state = "mournful"
	
	# Crops growing: add layers as entropy increases
	if conditions.crops_growing:
		active_layers["steel_guitar"] = true
	
	# Machine awakening: mechanical sounds intensify
	if conditions.machine_awakening:
		active_layers["percussion"] = true
		active_layers["brass"] = true
	
	# Emit signals for layer changes
	for layer_name in active_layers:
		if active_layers[layer_name] != old_layers[layer_name]:
			music_layer_changed.emit(layer_name, active_layers[layer_name])
			_update_layer_audio(layer_name, active_layers[layer_name])

func _update_layer_audio(layer_name: String, active: bool):
	## Start or stop audio layer
	var player = audio_players.get(layer_name)
	if not player:
		return
	
	if active:
		# Start playing (if audio stream loaded)
		# if audio_streams.has(layer_name):
		# 	player.stream = audio_streams[layer_name]
		# 	player.play()
		pass
	else:
		# Fade out and stop
		player.stop()

func generate_chord_progression(length: int = 4) -> Array[int]:
	## Generate a chord progression using Markov chain
	var progression: Array[int] = []
	var current_state = "i"  # Start on minor tonic
	
	for i in length:
		progression.append(_state_to_chord(current_state))
		# Get next state from Markov chain
		var transitions = chord_markov.get(current_state, [])
		if transitions.is_empty():
			break
		
		var rand_val = randf()
		var cumulative = 0.0
		for transition in transitions:
			cumulative += transition[1]
			if rand_val <= cumulative:
				current_state = transition[0]
				break
	
	return progression

func _state_to_chord(state: String) -> int:
	## Convert Roman numeral state to MIDI chord root
	# Simplified: returns root note offset for now
	# Could be expanded to return full chord (root, third, fifth)
	var offsets = {
		"i": 0,   # C
		"iv": 5,  # F
		"v": 7,   # G
		"vi": 9   # A
	}
	return root_note + offsets.get(state, 0)

func play_procedural_phrase():
	## Play a generated phrase based on current state
	chord_progression = generate_chord_progression(4)
	current_chord_index = 0
	_play_next_chord()

func _play_next_chord():
	## Play the next chord in the progression
	if current_chord_index >= chord_progression.size():
		current_chord_index = 0
	
	var chord_root = chord_progression[current_chord_index]
	# Synthesize or trigger MIDI for this chord
	_trigger_chord(chord_root)
	
	current_chord_index += 1
	
	# Schedule next chord based on tempo
	var next_time = 60.0 / tempo * 4.0  # 4/4 time, whole note per chord
	get_tree().create_timer(next_time).timeout.connect(_play_next_chord)

func _trigger_chord(root_note: int):
	## Trigger chord playback (would integrate with actual audio/MIDI)
	# This is pseudocode - would need actual synthesis or MIDI playback
	# For now, just emit a signal that could be handled by external systems
	pass

# Property accessors
var state: String:
	get:
		return current_state
	set(value):
		current_state = value

func set_tempo(bpm: float):
	tempo = bpm

func get_tempo() -> float:
	return tempo

