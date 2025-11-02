extends Control
class_name FamilyTreeUI

## Family tree UI showing bloodline history and portraits

signal portrait_selected(character_id: String)
signal generation_selected(generation: int)

@onready var tree_container: Control = $ScrollContainer/TreeContainer
@onready var generation_list: ItemList = $SidePanel/GenerationList
@onready var portrait_display: TextureRect = $PortraitPanel/PortraitDisplay
@onready var character_info: RichTextLabel = $PortraitPanel/CharacterInfo

var lineage_system: LineageSystem
var npc_system: NPCSystem
var heirloom_system: HeirloomSystem

var selected_generation: int = 1
var selected_character: Dictionary = {}

func _ready():
	set_visible(false)
	lineage_system = get_tree().get_first_node_in_group("lineage") as LineageSystem
	npc_system = get_tree().get_first_node_in_group("npc_system") as NPCSystem
	heirloom_system = get_tree().get_first_node_in_group("heirlooms") as HeirloomSystem
	
	if generation_list:
		generation_list.item_selected.connect(_on_generation_selected)

func show_family_tree():
	## Show family tree interface
	set_visible(true)
	_update_tree()

func hide_family_tree():
	## Hide family tree
	set_visible(false)

func _update_tree():
	## Update family tree display
	if not lineage_system:
		return
	
	var lineage_data = lineage_system.get_lineage_data()
	var generations = lineage_data.get("generations", [])
	
	# Update generation list
	if generation_list:
		generation_list.clear()
		for gen_data in generations:
			var gen_num = gen_data.get("generation", 1)
			var successor = gen_data.get("successor", {})
			var name = successor.get("name", "Unknown")
			generation_list.add_item("Generation " + str(gen_num) + ": " + name)
	
	# Draw tree
	_draw_family_tree(generations)

func _draw_family_tree(generations: Array):
	## Draw visual family tree
	if not tree_container:
		return
	
	# Clear existing nodes
	for child in tree_container.get_children():
		child.queue_free()
	
	# Create tree nodes for each generation
	for gen_data in generations:
		var gen_num = gen_data.get("generation", 1)
		var successor = gen_data.get("successor", {})
		
		var node = _create_tree_node(gen_num, successor)
		tree_container.add_child(node)
		
		# Position nodes (simplified layout)
		node.position = Vector2(50, gen_num * 120)

func _create_tree_node(generation: int, character: Dictionary) -> Control:
	## Create a tree node for a character
	var node = Panel.new()
	node.custom_minimum_size = Vector2(200, 100)
	
	# Portrait (placeholder)
	var portrait = TextureRect.new()
	portrait.name = "Portrait"
	portrait.custom_minimum_size = Vector2(64, 64)
	portrait.position = Vector2(10, 10)
	node.add_child(portrait)
	
	# Character name
	var name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.text = character.get("name", "Unknown")
	name_label.position = Vector2(80, 10)
	node.add_child(name_label)
	
	# Generation label
	var gen_label = Label.new()
	gen_label.name = "GenLabel"
	gen_label.text = "Gen " + str(generation)
	gen_label.position = Vector2(80, 35)
	node.add_child(gen_label)
	
	# Traits
	var traits_label = Label.new()
	traits_label.name = "TraitsLabel"
	var traits = character.get("traits", [])
	traits_label.text = ", ".join(traits.slice(0, 3))
	traits_label.position = Vector2(80, 55)
	traits_label.add_theme_font_size_override("font_size", 10)
	node.add_child(traits_label)
	
	# Connect click
	node.gui_input.connect(func(event): _on_node_clicked(event, character))
	
	return node

func _on_node_clicked(event: InputEvent, character: Dictionary):
	## Handle tree node click
	if event is InputEventMouseButton and event.pressed:
		selected_character = character
		_display_character_info(character)
		portrait_selected.emit(character.get("id", ""))

func _on_generation_selected(index: int):
	## Handle generation selection
	selected_generation = index + 1
	_update_tree()

func _display_character_info(character: Dictionary):
	## Display character information in portrait panel
	var name = character.get("name", "Unknown")
	var age = character.get("age", 0)
	var traits = character.get("traits", [])
	var parent1 = character.get("parent1", "")
	var parent2 = character.get("parent2", "")
	
	var info_text = "[b]" + name + "[/b]\n"
	info_text += "Age: " + str(age) + "\n"
	info_text += "Generation: " + str(character.get("generation", 1)) + "\n\n"
	
	if not parent1.is_empty() or not parent2.is_empty():
		info_text += "Parents: " + parent1
		if not parent2.is_empty():
			info_text += " & " + parent2
		info_text += "\n\n"
	
	if not traits.is_empty():
		info_text += "Traits: " + ", ".join(traits) + "\n"
	
	if character_info:
		character_info.text = info_text
	
	# Load portrait (would use portrait generation system)
	_load_portrait(character)

func _load_portrait(character: Dictionary):
	## Load character portrait
	# Would use procedural portrait generation based on traits/appearance_seed
	var portrait_seed = character.get("appearance_seed", 0)
	
	# Placeholder: would generate or load portrait
	if portrait_display:
		# portrait_display.texture = _generate_portrait(portrait_seed, character)
		pass

func get_character_portrait(character: Dictionary) -> Texture2D:
	## Get or generate character portrait
	var portrait_seed = character.get("appearance_seed", 0)
	var traits = character.get("traits", [])
	var faction = character.get("faction", "")
	var age = character.get("age", 18)
	
	# Would use procedural portrait generator
	# For now, return placeholder
	return null

