extends CollisionShape2D
class_name crossroads_object

enum type_object {NONE, POINT, KEY, EXPLODE, ITEM, JIMBO}

@export var object : type_object
@export var nbt : Dictionary

func _ready() -> void:
	match object :
		type_object.JIMBO : redraw()

func  redraw() :
	match object :
		type_object.ITEM : 
			var spr : Sprite2D = get_node("sprite")
			spr.region_enabled = true
			spr.region_rect = nbt.get("item").rect
			if spr.region_rect.size.x == 64 :
				shape.size = Vector2(64, 32)
		type_object.JIMBO : 
			var spr : Sprite2D = get_node("weapon")
			spr.region_enabled = true
			spr.region_rect = nbt.get("item").rect
			nbt["points"] = nbt["item"].nbt["value"]
			#spr.scale = Vector2(.8, .8)

func use() :
	match object :
		type_object.ITEM : 
			if arc.user.inventory_add(nbt["item"]) : 
				queue_free()
				arc.one_shot_play({"path" = "user/click", "position" = global_position})
		type_object.POINT :
			var points = nbt.get("points", 257257)
			if arc.user.points >= points : 
				arc.user.points -= points
				queue_free()
				arc.canvas.redraw()
				arc.one_shot_play({"path" = "user/buy", "position" = global_position})
			else : arc.one_shot_play({"path" = "user/err", "position" = global_position})
		type_object.JIMBO :
			var points = nbt.get("points", 257257)
			if arc.user.points >= points : 
				arc.user.points -= points
				arc.item_create(nbt["item"], arc.user.global_position)
				arc.one_shot_play({"path" = "user/buy", "position" = global_position})
			else : arc.one_shot_play({"path" = "user/err", "position" = global_position})
