extends Resource
class_name crossroads_settings

@export var data : Dictionary
#@export var lange : Dictionary[String, String]
#const keys_default : Array[String] = ["start", "continue", "settings", "russian", "wussian", "english", "audio", "music"]
#const keys_russian : Array[String] = ["новый заход", "забеги", "настройке", "православный", "гоблинский", "американский", "звук", "фон %"]
#const keys_wussian : Array[String] = ["нови пвихот", "пводолщить", "щайник", "абищныи", "конатински", "щагнивающии", "щфук", "щадник %"]
#const keys_english : Array[String] = ["new run", "runs", "settings", "russian", "wusskii", "Americanian", "audio", "ambient %"]

# ля єт гиніально, моя самая лучашя разработка
# надо сделать патент, чтоб другие не использовали Dictionary
# в сохранении настроек и прочего

func default_fill() :
	data["skin"] = "res://pics/Skins/0.png"
	data["volume"] = 1.2
	data["ambient"] = 1.2
	data["lange"] = "english"
	data["fullscreen"] = false
	data["vsync"] = false
	data["username"] = "username"
	data["decal"] = 255
	arc.settings_save()
	#lange_fill()

#func lange_fill(local_lange : String = "english") :
	#lange.clear()
	#match local_lange :
		#"russian" :
			#for i in range(keys_default.size()) :
				#lange.set(keys_default[i], data[local_lange[i]])
	#arc.emit_signal("retranslate")

#func get_word(id : String) -> String :
	#return lange.get(id,"")
