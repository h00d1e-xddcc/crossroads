extends Node2D
class_name crossroads_map

@export var layers = Array[crossroads_maplayer]

func _ready() -> void:
	arc_server.just_spawn()
