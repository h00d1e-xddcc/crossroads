extends Node2D
class_name root

@onready var atlas : Texture = preload("res://pics/tiles.ase")
@onready var user : crossroads_user
@onready var canvas : crossroads_canvas
@export var settings : crossroads_settings
@export var is_classic : bool = true
@export var decals : Array[Sprite2D]
@export var decals_write : int = -1
@export var timer : float
@export var difficulty : Array[int]
signal retranslate

func get_item(item_name : String = "") -> crossroads_item :
	var loaded_item = load("res://resources/items/" + item_name + ".tres")
	if loaded_item != null : 
		var item = loaded_item.duplicate(true)
		item.nbt["name"] = loaded_item.resource_name
		return item
	else : 
		ARC_CONSOLE.print_output("BAD REQUEST ITEM  -> `" + item_name + "`")
		return null

func get_texture(sprite_name : String) -> Rect2 :
	#print("get sprite -> " + sprite_name)
	match sprite_name :
		"hand0" : return Rect2(1184,2016,32,32)
		"bullet" : return Rect2(1791,1935, 5, 4)
		"magazine0" : return Rect2(1808,1936, 8, 16)
		"magazine1" : return Rect2(1816,1936, 11, 16)
		"shell" : return Rect2(1791,1939, 6, 4)
		"gas" : return Rect2(1696,1920,32,32)
		"zombie0" : return Rect2(736, 2016, 32, 32)
		"zombie1" : return Rect2(736, 1984, 32, 32)
		"zombie2" : return Rect2(736, 1952, 32, 32)
		"zombie3" : return Rect2(736, 1920, 32, 32)
		"mom" : return Rect2(736, 1920 - 32, 32, 32)
		"null", "" : return Rect2(1184,32,32,32)
		_ : 
			ARC_CONSOLE.print_output("BAD REQUEST IMAGE -> `" + sprite_name + "`")
			return Rect2(1184,32,32,32)

func get_sprite_under_mouse() -> Sprite2D:
	var mouse_pos = get_global_mouse_position()

	for sprite in get_tree().get_nodes_in_group("sprites"):
		if sprite is Sprite2D:
			var rect = Rect2(sprite.global_position - sprite.texture.get_size() / 2,sprite.texture.get_size())
			if rect.has_point(mouse_pos):
				return sprite

	return null

func item_create(item : crossroads_item, pos : Vector2 = Vector2.ZERO) : 
	if item != null :
		var prefab : crossroads_object = preload("res://prefabs/objects/item.tscn").instantiate()
		get_node("/root/main/map/items").add_child(prefab)
		prefab.nbt["item"] = item.duplicate(true)
		if pos == Vector2.ZERO : prefab.global_position = arc.user.global_position
		else : prefab.global_position = pos
		prefab.redraw()

func one_shot_play(d : Dictionary = {"path" = "", "type" = "2d","volume" = 0, "delay" = 0.0, "max_distance" = 0, "second" = 0, "random" = false, "position" = Vector2.ZERO, "format" = ".ogg", "pitch" = 1, "random_pitch" = true,}) -> float :
	var flags : Dictionary = {"path" = d.get("path", ""), "volume" = d.get("volume", 0), "delay" = d.get("delay", 0.0), "random" = d.get("random", false), "type" = d.get("type", "2d"), "second" = d.get("second", 0), "position" = d.get("position", Vector2.ZERO), "format" = d.get("format", ".ogg"), "pitch" = d.get("pitch", 1), "random_pitch" = d.get("random_pitch", true) }
	var source
	if flags.get("path") == "" : return -1
	#print("now play -> "+ flags["path"])
	var stream : AudioStream = load("res://audio/" + flags.get("path") + flags.get("format"))
	if stream == null : stream = preload("res://audio/user/err.ogg")
	match flags["type"] :
		"2d" : 
			source = AudioStreamPlayer2D.new()
			get_tree().root.add_child(source)
			#source.max_distance = flags.get("max_distance", 0)
			if flags.get("position", Vector2.ZERO) != Vector2.ZERO : source.global_position = flags["position"]
			#source.attenuation_filter_db = -24
			#source.attenuation_filter_cutoff_hz = 4000
		_ : 
			source = AudioStreamPlayer.new()
			arc.add_child(source)

	source.pitch_scale = flags["pitch"]
	source.volume_db = flags.get("volume", 0)
	source.volume_db = (source.volume_db + 10)  * arc.settings.data["volume"]
	source.stream = stream
	source.name = flags["path"]
	source.finished.connect(func() : source.queue_free())
	
	if flags["random_pitch"] == true : source.pitch_scale = randf_range(0.85,1.15)
	if flags["random"] == true : source.play(randf_range(0, stream.get_length()))
	if flags.get("delay") > 0 : await get_tree().create_timer(flags["delay"]).timeout
	else : source.play(flags["second"])
	return stream.get_length()

#region settings
func settings_load() -> bool : 
	if FileAccess.file_exists("user://crossroads.tres") : 
		arc.settings = ResourceLoader.load("user://crossroads.tres") as crossroads_settings
		if arc.settings.data.get("fullscreen", false) : get_window().mode = Window.MODE_FULLSCREEN
		if arc.settings.data.get("vsync", false) : DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else : DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		return true
	return false

func settings_create() :
	arc.settings = crossroads_settings.new()
	arc.settings.default_fill()

func settings_save() :
	ResourceSaver.save(settings, "user://crossroads.tres")
#endregion

func decal_create(decal : String, pos : Vector2, rot : float, scl : float = 1.5, is_random : bool = true) :
	if arc.settings.data["decal"] == 0 : return
	var dcl : Sprite2D = preload("res://prefabs/objects/decal.tscn").instantiate()
	get_tree().root.add_child(dcl)
	decals_write += 1
	if decals_write >= arc.settings.data.get("decal", 255) : decals_write = 0
	if decals[decals_write] != null : decals[decals_write].queue_free()
	decals.set(decals_write,dcl)
	dcl.region_rect = arc.get_texture(decal)
	dcl.global_position  = pos
	dcl.global_rotation_degrees = rot
	#dcl.scale = Vector2.ONE * scl
	if is_random :
		dcl.global_position += (Vector2(randf_range(-1,1), randf_range(-1,1)) * randf_range(20,5))
		dcl.global_rotation += randf_range(-360, 360)

func decal_clear() :
	for i in decals :
		if is_instance_valid(i):
			i.queue_free()
	decals.clear()
	decals_write = -1
	arc.decals.resize(arc.settings.data["decal"])

#func spawn()
				#var summoning : String = str(comm.get(1))
				#var loaded_entity = load("res://prefabs/entity/" + summoning + ".tscn")
				#if loaded_entity != null :
					#var entity = loaded_entity.instantiate()
					#get_tree().root.add_child(entity)
					#entity.position = arc.user.position

func console_print(data) : 
	get_node("/root/ARC_CONSOLE").print_output(data)
