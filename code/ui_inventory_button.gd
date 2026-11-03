extends Button
class_name crossroads_ui_inventory_button

@export var texture : TextureRect
@export var input : Label

func clear() :
	texture.texture.region = Rect2(1184,32,32,32)
