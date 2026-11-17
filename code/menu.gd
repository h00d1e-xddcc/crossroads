extends Control

@export var buttons : Array[crossroads_button]

func _ready() -> void :
	if arc.settings_load() : pass
	else : arc.settings_create()
	#arc.settings.lange_fill()

	$main.visible = true
	$settings.visible = false
	$main/vessel/name.text = arc.settings.data.get("username", "username")
	$ambient.volume_db = 10  * arc.settings.data["ambient"]
	$ambient.play()
	$map.visible = false
	arc.emit_signal("retranslate")
	TranslationServer.set_locale(arc.settings.data.get("lange", "english"))

	for i in buttons.size() :
		buttons[i].redraw()

func _on_name_text_submitted(new_text: String) -> void:
	arc.settings.data.set("username", new_text)
	arc.settings_save()

func _on_start_pressed() -> void:
	$map.visible = true
	$main.visible = false
	$settings.visible = false
	#SceneManager.change_scene("res://prefabs/main.tscn")

func _open_link(extra_arg_0: String) -> void:
	match extra_arg_0 :
		"steam" : OS.shell_open("https://store.steampowered.com/app/959030/Zombie_Cubes/")
		"facebook" : OS.shell_open("https://www.facebook.com/MayoNinjaGames")
		"twitter" : OS.shell_open("https://x.com/MayoNinja_")
		"github" : OS.shell_open("https://github.com/h00d1e-xddcc/crossroads")
		_ : OS.shell_open(extra_arg_0)

func _on_skin() -> void:
	$main/vessel/paper.visible = !$main/vessel/paper.visible

func _on_settings_pressed() -> void:
	$main.visible = false
	$settings/sound.visible = false
	$settings.visible = true
	$settings/buttons.visible = true
	$settings/responce. visible = false

func _on_back_pressed() -> void:
	$main.visible = !false
	$settings.visible = !true

func _menu_open(extra_arg_0: String) -> void:
	$settings/buttons.visible = false
	match extra_arg_0 :
		"sound" : $settings/sound.visible = true
		"credit": $settings/responce.visible = true
