extends Control

@export var buttons : Array[crossroads_button]

func _ready() -> void :
	if arc.settings_load() : pass
	else : arc.settings_create()
	#arc.settings.lange_fill()

	$main/vessel/name.text = arc.settings.data.get("username", "username")
	$ambient.volume_db = 10  * arc.settings.data["ambient"]
	$ambient.play()
	arc.emit_signal("retranslate")
	TranslationServer.set_locale(arc.settings.data.get("lange", "english"))

	for i in buttons.size() :
		buttons[i].redraw()

func _on_name_text_submitted(new_text: String) -> void:
	arc.settings.data.set("username", new_text)
	arc.settings_save()

func _on_start_pressed() -> void:
	SceneManager.change_scene("res://prefabs/main.tscn")

func _open_link(extra_arg_0: String) -> void:
	OS.shell_open(extra_arg_0)

func _on_skin() -> void:
	$main/vessel/paper.visible = !$main/vessel/paper.visible
