extends Control
class_name CharacterCreation

## Character and family creation interface

signal character_created(character_data: Dictionary)
signal creation_cancelled()

var character_data: Dictionary = {
	"first_name": "",
	"family_name": "",
	"trait1": "",
	"trait2": "",
	"origin": "",
	"starting_heirloom": "",
	"portrait_seed": 0
}

var available_traits: Array[Dictionary] = []
var available_heirlooms: Array[Dictionary] = []
var available_origins: Array[Dictionary] = []

@onready var first_name_input: LineEdit = $VBoxContainer/NameSection/FirstNameInput
@onready var family_name_input: LineEdit = $VBoxContainer/NameSection/FamilyNameInput
@onready var trait1_dropdown: OptionButton = $VBoxContainer/TraitSection/Trait1Dropdown
@onready var trait2_dropdown: OptionButton = $VBoxContainer/TraitSection/Trait2Dropdown
@onready var origin_dropdown: OptionButton = $VBoxContainer/OriginSection/OriginDropdown
@onready var heirloom_list: ItemList = $VBoxContainer/HeirloomSection/HeirloomList
@onready var portrait_preview: TextureRect = $VBoxContainer/PortraitSection/PortraitPreview
@onready var character_info: RichTextLabel = $VBoxContainer/InfoSection/CharacterInfo
@onready var confirm_button: Button = $VBoxContainer/Buttons/ConfirmButton
@onready var cancel_button: Button = $VBoxContainer/Buttons/CancelButton

func _ready():
	_load_data()
	_populate_ui()
	_connect_signals()
	
	# Generate random portrait seed
	character_data["portrait_seed"] = randi()

const DataLoader = preload("res://scripts/DataLoader.gd")

func _load_data():
	## Load trait, heirloom, and origin data
	available_traits = DataLoader.load_json_file("res://data/rpg/rpg_traits.json")
	available_origins = DataLoader.load_json_file("res://data/family_identity/origins.json")
	
	# Load starting heirlooms
	var all_heirlooms = DataLoader.load_json_file("res://data/heirlooms/heirlooms.json")
	for heirloom in all_heirlooms:
		var gen_acquired = heirloom.get("generation_acquired", 1)
		if gen_acquired == 1:
			available_heirlooms.append(heirloom)

func _populate_ui():
	## Populate UI elements
	# Populate trait dropdowns
	if trait1_dropdown and trait2_dropdown:
		trait1_dropdown.clear()
		trait2_dropdown.clear()
		
		for trait in available_traits:
			var display_name = trait.get("display_name", trait.get("name", ""))
			trait1_dropdown.add_item(display_name)
			trait2_dropdown.add_item(display_name)
	
	# Populate origin dropdown
	if origin_dropdown:
		origin_dropdown.clear()
		for origin in available_origins:
			var name = origin.get("name", origin.get("id", ""))
			origin_dropdown.add_item(name)
	
	# Populate heirloom list
	if heirloom_list:
		heirloom_list.clear()
		for heirloom in available_heirlooms:
			var name = heirloom.get("name", "")
			var description = heirloom.get("description", "")
			heirloom_list.add_item(name + " - " + description)

func _connect_signals():
	## Connect UI signals
	if confirm_button:
		confirm_button.pressed.connect(_on_confirm_pressed)
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_pressed)
	
	if first_name_input:
		first_name_input.text_changed.connect(_on_name_changed)
	if family_name_input:
		family_name_input.text_changed.connect(_on_name_changed)
	
	if trait1_dropdown:
		trait1_dropdown.item_selected.connect(_on_trait_selected.bind(1))
	if trait2_dropdown:
		trait2_dropdown.item_selected.connect(_on_trait_selected.bind(2))
	
	if origin_dropdown:
		origin_dropdown.item_selected.connect(_on_origin_selected)
	
	if heirloom_list:
		heirloom_list.item_selected.connect(_on_heirloom_selected)
	
	# Update preview on any change
	call_deferred("_update_preview")

func _on_name_changed(_text: String):
	_update_preview()

func _on_trait_selected(trait_num: int, index: int):
	## Handle trait selection
	var trait_key = "trait" + str(trait_num)
	if index < available_traits.size():
		var trait = available_traits[index]
		character_data[trait_key] = trait.get("name", "")
		_update_preview()

func _on_origin_selected(index: int):
	## Handle origin selection
	if index < available_origins.size():
		var origin = available_origins[index]
		character_data["origin"] = origin.get("id", "")
		_update_preview()

func _on_heirloom_selected(index: int):
	## Handle heirloom selection
	if index < available_heirlooms.size():
		var heirloom = available_heirlooms[index]
		character_data["starting_heirloom"] = heirloom.get("id", "")
		_update_preview()

func _update_preview():
	## Update character preview and info
	character_data["first_name"] = first_name_input.text if first_name_input else ""
	character_data["family_name"] = family_name_input.text if family_name_input else ""
	
	# Update portrait preview
	_update_portrait()
	
	# Update character info
	_update_character_info()

func _update_portrait():
	## Update portrait preview
	if portrait_preview:
		var seed = character_data.get("portrait_seed", 0)
		var traits = []
		if not character_data.get("trait1", "").is_empty():
			traits.append(character_data["trait1"])
		if not character_data.get("trait2", "").is_empty():
			traits.append(character_data["trait2"])
		
		# Would generate portrait from seed and traits
		# For now, placeholder
		pass

func _update_character_info():
	## Update character info display
	if not character_info:
		return
	
	var info_text = ""
	
	var first_name = character_data.get("first_name", "")
	var family_name = character_data.get("family_name", "")
	if not first_name.is_empty() and not family_name.is_empty():
		info_text += "[b]" + first_name + " " + family_name + "[/b]\n\n"
	
	# Traits
	var trait1 = character_data.get("trait1", "")
	var trait2 = character_data.get("trait2", "")
	if not trait1.is_empty() or not trait2.is_empty():
		info_text += "[b]Traits:[/b]\n"
		for trait_data in available_traits:
			var trait_name = trait_data.get("name", "")
			if trait_name == trait1 or trait_name == trait2:
				var display_name = trait_data.get("display_name", trait_name)
				var description = trait_data.get("description", "")
				info_text += "• " + display_name + ": " + description + "\n"
		info_text += "\n"
	
	# Origin
	var origin_id = character_data.get("origin", "")
	if not origin_id.is_empty():
		for origin in available_origins:
			if origin.get("id") == origin_id:
				info_text += "[b]Origin:[/b] " + origin.get("name", "") + "\n"
				info_text += origin.get("description", "") + "\n\n"
	
	# Heirloom
	var heirloom_id = character_data.get("starting_heirloom", "")
	if not heirloom_id.is_empty():
		for heirloom in available_heirlooms:
			if heirloom.get("id") == heirloom_id:
				info_text += "[b]Starting Heirloom:[/b] " + heirloom.get("name", "") + "\n"
	
	# World Impact Preview
	info_text += "\n[b]World Impact:[/b]\n"
	info_text += _get_world_impact_preview()
	
	character_info.text = info_text

func _get_world_impact_preview() -> String:
	## Get world impact preview from selected traits/origin
	var impact_text = ""
	var faction_opinions: Dictionary = {}
	
	# Calculate faction opinions from traits
	for trait_data in available_traits:
		var trait_name = trait_data.get("name", "")
		if trait_name == character_data.get("trait1", "") or trait_name == character_data.get("trait2", ""):
			var world_impact = trait_data.get("world_impact", {})
			var opinions = world_impact.get("faction_opinions", {})
			for faction in opinions:
				if not faction_opinions.has(faction):
					faction_opinions[faction] = 0
				faction_opinions[faction] += opinions[faction]
	
	# Add origin opinions
	var origin_id = character_data.get("origin", "")
	if not origin_id.is_empty():
		for origin in available_origins:
			if origin.get("id") == origin_id:
				var trait_match = _find_trait_by_name(origin_id)
				if trait_match:
					var world_impact = trait_match.get("world_impact", {})
					var opinions = world_impact.get("faction_opinions", {})
					for faction in opinions:
						if not faction_opinions.has(faction):
							faction_opinions[faction] = 0
						faction_opinions[faction] += opinions[faction]
	
	# Format faction opinions
	if not faction_opinions.is_empty():
		for faction in faction_opinions:
			var value = faction_opinions[faction]
			if value != 0:
				var sign = "+" if value > 0 else ""
				impact_text += "• " + faction + ": " + sign + str(value) + "\n"
	
	return impact_text

func _find_trait_by_name(trait_name: String) -> Dictionary:
	## Find trait data by name
	for trait in available_traits:
		if trait.get("name") == trait_name:
			return trait
	return {}

func _on_confirm_pressed():
	## Confirm character creation
	# Validate
	if not _validate_character():
		return
	
	# Create character
	character_created.emit(character_data)
	_initialize_character()
	
	# Transition to prologue after initialization
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/ui/prologue.tscn")

func _on_cancel_pressed():
	## Cancel character creation
	creation_cancelled.emit()

func _validate_character() -> bool:
	## Validate character data
	if character_data.get("first_name", "").is_empty():
		push_warning("Please enter a first name")
		return false
	
	if character_data.get("family_name", "").is_empty():
		push_warning("Please enter a family name")
		return false
	
	if character_data.get("trait1", "").is_empty():
		push_warning("Please select a first trait")
		return false
	
	if character_data.get("trait2", "").is_empty():
		push_warning("Please select a second trait")
		return false
	
	if character_data.get("origin", "").is_empty():
		push_warning("Please select an origin")
		return false
	
	if character_data.get("starting_heirloom", "").is_empty():
		push_warning("Please select a starting heirloom")
		return false
	
	return true

func _initialize_character():
	## Initialize player character from creation data
	var game_manager = GameManager.instance
	if not game_manager:
		push_error("GameManager not found!")
		return
	
	var player = game_manager.player
	if not player:
		push_error("Player not found!")
		return
	
	# Set names (use character_name to avoid Node.name conflict)
	var full_name = character_data.get("first_name", "") + " " + character_data.get("family_name", "")
	player.character_name = full_name
	player.name = full_name  # Set Node.name for consistency
	
	# Set traits
	var traits: Array[String] = []
	var trait1 = character_data.get("trait1", "")
	var trait2 = character_data.get("trait2", "")
	if not trait1.is_empty():
		traits.append(trait1)
	if not trait2.is_empty():
		traits.append(trait2)
	player.traits = traits
	
	# Apply trait stat modifiers
	_apply_trait_modifiers(player, trait1, trait2)
	
	# Apply world impact
	_apply_world_impact(character_data)
	
	# Initialize heirloom
	var heirloom_system = get_tree().get_first_node_in_group("heirlooms") as HeirloomSystem
	if heirloom_system:
		var heirloom_id = character_data.get("starting_heirloom", "")
		if not heirloom_id.is_empty():
			heirloom_system.acquire_heirloom(heirloom_id, 1)
	
	# Initialize family identity
	var family_identity = get_tree().get_first_node_in_group("family_identity") as FamilyIdentitySystem
	if family_identity:
		family_identity.initialize_family(character_data)
	
	# Save creation data
	_save_character_creation()

func _apply_trait_modifiers(player: Player, trait1: String, trait2: String):
	## Apply trait stat modifiers to player
	for trait_data in available_traits:
		var trait_name = trait_data.get("name", "")
		if trait_name == trait1 or trait_name == trait2:
			var modifiers = trait_data.get("stat_modifiers", {})
			for stat in modifiers:
				var current_value = player.stats.get(stat, 10)
				player.stats[stat] = current_value + modifiers[stat]

func _apply_world_impact(character_data: Dictionary):
	## Apply world impact from traits and origin
	# Faction opinions
	var faction_opinions: Dictionary = {}
	
	# From traits
	for trait_data in available_traits:
		var trait_name = trait_data.get("name", "")
		if trait_name == character_data.get("trait1", "") or trait_name == character_data.get("trait2", ""):
			var world_impact = trait_data.get("world_impact", {})
			var opinions = world_impact.get("faction_opinions", {})
			for faction in opinions:
				if not faction_opinions.has(faction):
					faction_opinions[faction] = 0
				faction_opinions[faction] += opinions[faction]
	
	# From origin
	var origin_id = character_data.get("origin", "")
	var trait_match = _find_trait_by_name(origin_id)
	if trait_match:
		var world_impact = trait_match.get("world_impact", {})
		var opinions = world_impact.get("faction_opinions", {})
		for faction in opinions:
			if not faction_opinions.has(faction):
				faction_opinions[faction] = 0
			faction_opinions[faction] += opinions[faction]
	
	# Apply to player
	var player = GameManager.instance.player if GameManager.instance else null
	if player:
		for faction in faction_opinions:
			if not player.faction_relations.has(faction):
				player.faction_relations[faction] = 0
			player.faction_relations[faction] += faction_opinions[faction]
	
	# NPC opinion penalties from flaws
	var npc_system = get_tree().get_first_node_in_group("npc_system") as NPCSystem
	if npc_system:
		for trait_data in available_traits:
			var trait_name = trait_data.get("name", "")
			var category = trait_data.get("category", "")
			if trait_name == character_data.get("trait1", "") or trait_name == character_data.get("trait2", ""):
				if category == "flaw":
					var world_impact = trait_data.get("world_impact", {})
					var npc_penalty = world_impact.get("npc_memory_penalty", 0)
					if npc_penalty < 0:
						# Apply penalty to all NPCs
						for npc_id in npc_system.npcs:
							var current_opinion = npc_system.get_npc_opinion(npc_id)
							npc_system.change_opinion(npc_id, npc_penalty, "bloodline_flaw")

func _save_character_creation():
	## Save character creation data
	var save_data = {
		"character_creation": character_data.duplicate(),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var file = FileAccess.open("user://character_creation.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

