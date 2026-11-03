extends LineEdit
class_name crossroads_button

@export var label : Label
@export var translate : bool

func redraw() -> void:
	arc.retranslate.connect(redraw)
	if translate : label.text = tr(name)
	match name :
		"audio" :
			placeholder_text = str(0.0)
			text = str(arc.settings.data["volume"])
		"ambient" : 
			placeholder_text = str(0.0)
			text = str(arc.settings.data["ambient"])
		"decal" : 
			placeholder_text = str(255)
			text = str(arc.settings.data["decal"])

func _on_reset_pressed() -> void:
	match name :
		"volume":
			arc.settings.data["volume"] = 0.0
			arc.settings_save()
			text = str("0.0")
		"ambient" :
			arc.settings.data["ambient"] = 0.0
			arc.settings_save()
			text = str("0.0")
			if $/root/menu != null :
				$ambient.volume_db = 0
		"decal" :
			arc.settings.data["decal"] = 255
			arc.settings_save()
			text = str(255)
			arc.decal_clear()

func _on_text_submitted(new_text: String) -> void:
	match name :
		"audio" :
			var value : float = float(new_text) as float
			text = str(value)
			arc.settings.data["volume"] = value
			arc.settings_save()
			arc.one_shot_play({"path" = "user/gun"})
		"ambient" :
			var value : float = float(new_text) as float
			text = str(value)
			arc.settings.data["ambient"] = value
			arc.settings_save()
			if $/root/menu != null :
				$/root/menu/ambient.volume_db = 10  * arc.settings.data["ambient"]
		"decal" :
			var value : int = int(new_text) as int
			if value > -1 :
				arc.settings.data["decal"] = value
				arc.decal_clear()
				arc.settings_save()
			else :
				arc.settings.data["decal"] = 255
				arc.settings_save()
				text = str(255)
				arc.decal_clear()

	caret_column = 57
