extends Node
class_name ContentLoader

## Loads content packs and overrides default assets

signal content_loaded(pack_name: String)
signal content_reloaded()

var loaded_packs: Dictionary = {}
var asset_overrides: Dictionary = {
	"sprites": {},
	"audio": {},
	"shaders": {}
}

func _ready():
	_scan_content_packs()

func _scan_content_packs():
	## Scan for content packs
	var packs_dir = DirAccess.open("res://assets/packs")
	if packs_dir == null:
		push_warning("Content packs directory not found")
		return
	
	packs_dir.list_dir_begin()
	var pack_name = packs_dir.get_next()
	
	while pack_name != "":
		if packs_dir.current_is_dir() and pack_name != "." and pack_name != "..":
			var manifest_path = "res://assets/packs/" + pack_name + "/manifest.json"
			if ResourceLoader.exists(manifest_path):
				_load_pack(pack_name, manifest_path)
		pack_name = packs_dir.get_next()

func _load_pack(pack_name: String, manifest_path: String):
	## Load a content pack
	var file = FileAccess.open(manifest_path, FileAccess.READ)
	if file == null:
		push_warning("Failed to open manifest: " + manifest_path)
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("JSON parse error: " + json.get_error_message())
		return
	
	var manifest = json.get_data()
	loaded_packs[pack_name] = manifest
	
	# Load assets
	if manifest.has("sprites"):
		_load_sprites(pack_name, manifest.get("sprites", {}))
	
	if manifest.has("audio"):
		_load_audio(pack_name, manifest.get("audio", {}))
	
	if manifest.has("shaders"):
		_load_shaders(pack_name, manifest.get("shaders", []))
	
	content_loaded.emit(pack_name)

func _load_sprites(pack_name: String, sprites: Dictionary):
	## Load sprite assets
	for category in sprites:
		var files = sprites.get(category, [])
		for file_name in files:
			var full_path = "res://assets/packs/" + pack_name + "/sprites/" + category + "/" + file_name
			if ResourceLoader.exists(full_path):
				var texture = load(full_path)
				if texture:
					asset_overrides["sprites"][file_name] = texture

func _load_audio(pack_name: String, audio: Dictionary):
	## Load audio assets
	for category in audio:
		var files = audio.get(category, [])
		for file_name in files:
			var full_path = "res://assets/packs/" + pack_name + "/audio/" + category + "/" + file_name
			if ResourceLoader.exists(full_path):
				var stream = load(full_path)
				if stream:
					asset_overrides["audio"][file_name] = stream

func _load_shaders(pack_name: String, shaders: Array):
	## Load shader assets
	for shader_name in shaders:
		var full_path = "res://assets/packs/" + pack_name + "/shaders/" + shader_name
		if ResourceLoader.exists(full_path):
			var shader = load(full_path)
			if shader:
				asset_overrides["shaders"][shader_name] = shader

func get_sprite(name: String) -> Texture2D:
	## Get sprite texture (override or default)
	if asset_overrides["sprites"].has(name):
		return asset_overrides["sprites"][name]
	
	# Fallback to default
	var default_path = "res://assets/sprites/" + name
	if ResourceLoader.exists(default_path):
		return load(default_path)
	
	return null

func get_audio(name: String) -> AudioStream:
	## Get audio stream (override or default)
	if asset_overrides["audio"].has(name):
		return asset_overrides["audio"][name]
	
	# Fallback to default
	var default_path = "res://assets/sounds/" + name
	if ResourceLoader.exists(default_path):
		return load(default_path)
	
	return null

func get_shader(name: String) -> Shader:
	## Get shader (override or default)
	if asset_overrides["shaders"].has(name):
		return asset_overrides["shaders"][name]
	
	# Fallback to default
	var default_path = "res://shaders/" + name
	if ResourceLoader.exists(default_path):
		return load(default_path)
	
	return null

func reload_packs():
	## Hot-reload all content packs
	asset_overrides = {
		"sprites": {},
		"audio": {},
		"shaders": {}
	}
	loaded_packs.clear()
	_scan_content_packs()
	content_reloaded.emit()

