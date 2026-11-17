extends CanvasLayer
class_name default_console

@onready var output : RichTextLabel = $panel/output
@onready var input : LineEdit = $panel/input
@export var last_command : String
@export var last_commands : Array[String]
@export var selected_command : int = -1

func print_output(data) :
	if output.text == " " : output.text = ""
	else : output.text += "\n" + str(data)
	#print(data)

func _on_input_text_submitted(new_text: String) -> void:
	if new_text == "!!" : 
		_on_input_text_submitted(last_command)
		return
	last_commands.append(new_text)
	if new_text[0] == "$" :
		last_command = new_text
		new_text[0] = ""
		var comm = new_text.split(" ")
		match comm[0] :
			"h" : 
				print_output("{h}elp")
				print_output("{cl}ear")
				print_output("{r}e{d}raw")
				print_output("{r}edraw{s}lots")
				print_output("{p}oin{ts} (int value)")
				print_output("{s}et_{l}ocale (english,engliw,russian,wussian)")
				print_output("{trans}late")
				print_output("{squad}_suicide_attack")
				print_output("{i}tem (item_name)")
				print_output("{s}ummon (entity_name) (x) (y)")
				print_output("{i}tem_{l}ist")
				print_output("{e}ntity_{l}ist")
			"i" :
				var item_to_create : String = comm.get(1) as String
				var item_load : crossroads_item = arc.get_item(item_to_create)
				if item_load != null :
					arc.item_create(item_load)
			"rd" : arc.canvas.redraw()
			"rs" : arc.canvas.slots_redraw()
			"il" : print_output("1911, bucky, nature, sheriff, gas")
			"el" : print_output("explode, acid, default, kamikadze, spitter")
			"cl" : output.text = arc.data["ver"]
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
			"nc" :
				if arc.user.collision_mask == 0 :
					arc.user.collision_layer = 15
				else : arc.user.collision_mask = 0
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
			"squad" :
				arc.summon_entity("explode", arc.user.global_position)
			"damage" : 
				var damage = int(comm.get(1))
				arc.user.damage(damage)
			"s" : 
				var summoning : String = str(comm.get(1))
				var x : int = int(comm.get(2))
				var y : int = int(comm.get(3))
				if arc.entities.has(summoning) :
					arc.summon_entity(summoning, Vector2(x,y))
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
	#input.release_focus()
	input.grab_focus()

func _ready() -> void:
	$panel.visible = false
	output.text = arc.data["ver"]

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("console") : show_hide()
	if !input.has_focus() : return
	if Input.is_action_just_pressed("ui_up") : 
		var line = last_commands.get(selected_command + 1)
		if line != null :
			selected_command += 1
			input.caret_column = 57
			input.text = line
	if Input.is_action_just_pressed("ui_down") : 
		var line = last_commands.get(selected_command - 1)
		if line != null :
			selected_command -= 1
			input.caret_column = 57
			input.text = line


func show_hide() :
	get_node("panel").visible = !get_node("panel").visible
	if get_node("panel").visible == true :
		input.grab_focus()
		input.caret_column = 57
		selected_command = 0
