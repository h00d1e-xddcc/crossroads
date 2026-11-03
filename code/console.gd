extends CanvasLayer
class_name crossroad_console

@onready var output : RichTextLabel = $panel/output
@onready var input : LineEdit = $panel/input
@export var last_comma : String

func print_output(data) :
	if output.text == " " : output.text = ""
	else : output.text += "\n" + str(data)
	#print(data)

func _on_input_text_submitted(new_text: String) -> void:
	if new_text == "!!" : 
		_on_input_text_submitted(last_comma)
		return
	if new_text[0] == "$" :
		last_comma = new_text
		new_text[0] = ""
		var comm = new_text.split(" ")
		match comm[0] :
			"h" : 
				print_output("{h}elp")
				print_output("{cl}ear")
				print_output("{r}e{d}raw")
				print_output("{r}edraw{s}lots")
				print_output("{p}oin{ts} (int value)")
				print_output("{s}how_{c}ollision (walls,projectile,hole)")
				print_output("{s}et_{l}ocale (english,engliw,russian,wussian)")
				print_output("{trans}late")
				print_output("{i}tem (item_name)")
			"i" :
				var item_to_create : String = comm.get(1) as String
				var item_load : crossroads_item = arc.get_item(item_to_create)
				if item_load != null :
					arc.item_create(item_load)
			"rd" : arc.canvas.redraw()
			"rs" : arc.canvas.slots_redraw()
			"connect" : 
				var ip : String = comm.get(1) as String
				var ip_port : int = comm.get(2) as int
				arc_server.join(ip,ip_port)
			"join" : 
				arc_server.ip = "127.0.0.1"
				arc_server.port = 7778
				arc_server.open_host()
			"open_host" : 
				var ip_port : int = comm.get(1) as int
				var clients : int = comm.get(2) as int
				arc_server.port = ip_port
				arc_server.port = clients
				arc_server.open_host()
			"host" : 
				arc_server.host_game()
			"disconect" : 
				arc_server.disconnect_game()
			"rf" : 
				OS.move_to_trash("user://crossroads.tres")
			"trans" : arc.emit_signal("retranslate")
			"sc" :
				var layer : String = comm.get(1) as String
				var map : TileMapLayer = get_node("/root/main/map/" + layer)
				if map != null : map.visible = !map.visible
			"sl" : 
				var lange : String = comm.get(1) as String
				match lange :
					"russian", "wussian", "english", "engliw" :
						TranslationServer.set_locale(lange)
						arc.settings.data["lange"] = lange
						arc.settings_save()
				arc.emit_signal("retranslate")
			#"cl" : output.text = ""
			#"rsi" : arc.canvas.slots_input_redraw()
			"s" : 
				var summoning : String = str(comm.get(1))
				var loaded_entity = load("res://prefabs/entity/" + summoning + ".tscn")
				if loaded_entity != null :
					var entity = loaded_entity.instantiate()
					get_tree().root.add_child(entity)
					entity.position = arc.user.position
			"pts" : 
				var points : int = int(comm.get(1))
				arc.user.points = points
				arc.canvas.redraw()
			_ : 
				if new_text == "!!"  : pass
				else : print_output(new_text + ": command not found")
	else : print_output(arc.settings.data.get("username", "me") + " > " + new_text)
	#if new_text != "!!" : last_comma = new_text
	input.text = "" 
	input.release_focus()

func _ready() -> void:
	$panel.visible = false
	output.text = "crossroads v26.0.-1"

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("chat") : show_hide()
	if Input.is_action_just_pressed("console") : show_hide_command()

func show_hide() :
	get_node("panel").visible = !get_node("panel").visible
	if get_node("panel").visible == true : input.grab_focus()

func show_hide_command() :
	if arc.user != null : arc.user.item_hide()
	get_node("panel").visible = !get_node("panel").visible
	if get_node("panel").visible == true : input.grab_focus()
	input.text = "$"
	input.caret_column = 57
