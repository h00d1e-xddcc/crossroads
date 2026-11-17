extends Resource
class_name crossroads_settings

@export var data : Dictionary = {
	"skin" = "res://pics/Skins/0.png",
	"volume" = 1.2,
	"ambient" = 1.2,
	"lange" = "enghlish",
	"fullscreen" = false,
	"vsync" = 0,
	"username" = "jane_doe",
	"decal" = 257,
	"history" = []
}

func default_fill() :
	data["skin"] = "res://pics/Skins/0.png"
	data["volume"] = 1.2
	data["ambient"] = 1.2
	data["lange"] = "english"
	data["fullscreen"] = false
	data["vsync"] = false
	data["username"] = "jane_doe"
	data["decal"] = 257
	arc.settings_save()
