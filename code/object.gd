extends CollisionShape2D
class_name crossroads_object

enum type_object {NONE, POINT, KEY, SMELTER, ITEM, JIMBO, BUTTON, CARTON, TABLE}

@export var object : type_object
@export var nbt : Dictionary

func _ready() -> void:
	match object :
		type_object.JIMBO : redraw()

func  redraw() :
	match object :
		type_object.ITEM : 
			var spr : Sprite2D = get_node("sprite")
			if nbt.get("item", "").resource_name == "tar" :
				spr.region_rect = arc.get_texture("tar0")
				shape.size = Vector2(64,64)
			else :
				spr.region_enabled = true
				spr.region_rect = nbt.get("item").rect
				if spr.region_rect.size.x == 64 :
					shape.size = Vector2(64, 32) # над щоб коллізія подстраівалась
		type_object.JIMBO : 
			var spr : Sprite2D = get_node("weapon")
			spr.region_enabled = true
			spr.region_rect = nbt.get("item").rect
			nbt["points"] = nbt["item"].nbt["value"]
			#spr.scale = Vector2(.8, .8)

func use() :
	if arc.user.is_reloading : return
	match object :
		type_object.ITEM : 
			if arc.user.item.resource_name == "scrap" :
				pass
			var slot = arc.user.inventory.find(null)
			if slot == null : 
				arc.user.inventory_add(nbt["item"]) 
				queue_free()
				arc.one_shot_play({"path" = "user/click", "position" = global_position})
		type_object.POINT :
			var points = nbt.get("points", 257257)
			if arc.user.points >= points : 
				arc.user.points -= points
				queue_free()
				arc.canvas.redraw()
				arc.one_shot_play({"path" = "user/door_open", "position" = global_position})
			else : arc.one_shot_play({"path" = "user/err", "position" = global_position})
		type_object.JIMBO :
			var points = nbt.get("points", 257257)
			if arc.user.points >= points : 
				arc.user.points -= points
				arc.user.inventory_add(nbt["item"])
				arc.one_shot_play({"path" = "user/buy", "position" = global_position})
			else : arc.one_shot_play({"path" = "user/err", "position" = global_position})
		type_object.SMELTER :
			var item = arc.user.item
			if item != null : 
				arc.user.points += item.nbt.get("value") * .75
				arc.user.inventory.erase(arc.user.item)
				arc.user.item = null
				arc.canvas.redraw()
				arc.one_shot_play({"path" = "user/buy", "position" = global_position})
			else : arc.one_shot_play({"path" = "user/err", "position" = global_position})
		type_object.CARTON :
			if nbt["is_open"] == false :
				nbt.set("is_open", true)
				$sprite.region_rect = arc.get_texture("carton_open")
				arc.one_shot_play({"path" = "user/glass", "position" = global_position})
				arc.user.inventory_add(nbt[randi_range(0,3)])
				#await get_tree().create_timer(arc.data.get("difficulty").cd_carton, 1).timeout
				await get_tree().create_timer(1).timeout
				$sprite.region_rect = arc.get_texture("carton")
				nbt.set("is_open", false)
		#type_object.TABLE :
			#if nbt.get("item") != null :
#				
