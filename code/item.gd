extends Resource
class_name crossroads_item

enum type_item {NONE, HANDGUN, SHOTGUN, CONSUMBLE, CRAFT}
enum type_queue{NONE, SINGLE, SEMI, AUTO, SPAM}

@export var texture : Texture
@export var rect : Rect2
@export var type : type_item
@export var nbt : Dictionary
@export var queue : type_queue
