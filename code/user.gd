extends CharacterBody2D
class_name crossroads_user

@export var points : int
@export var move_speed: float = 220.0
@export var hp : int = 3
@export var kills : int = 0
@export var light : PointLight2D
@export var area : ShapeCast2D
@export var fire : Node2D
@export var iddqd : bool = false
@export var inventory : Array[crossroads_item]
@export var item : crossroads_item
@export var item_selected : int = -1
@export var is_reloading = false
@export var is_can_shoot = true
@export var nearest_collision : crossroads_object

var reload_hold : float
var is_holding : bool

#region ready_process_singlas
func _ready() -> void:
	arc.user = $/root/main/user
	arc.canvas = $/root/main/canvas
	if arc.is_classic : 
		arc.canvas.load_classic()
		inventory.resize(2)
	else :
		arc.canvas.slots_input_redraw()
		arc.canvas.weapon_redraw(arc.get_texture(""))

func _physics_process(_delta: float) -> void:
	var input_direction := Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * move_speed
	move_and_slide()

	look_at(get_global_mouse_position())
	INPUT(_delta)
	if nearest_collision != null : arc.canvas.pts_calculate(nearest_collision.nbt["points"])
	else : arc.canvas.pts_calculate(0)

	nearest_collision = null
	area.force_shapecast_update()
	if area.is_colliding():
		for i in range(area.get_collision_count()):
			var obj = area.get_collider(i)
			if obj is TileMapLayer : return
			var shape_index = area.get_collider_shape(i)
			var owner_id = obj.shape_find_owner(shape_index)
			var collision_shape_node = obj.shape_owner_get_owner(owner_id) as CollisionShape2D
			if collision_shape_node is crossroads_object: nearest_collision = collision_shape_node as crossroads_object

func _on_body_exited(node2d : Node2D) :
	print("exit " + node2d.name)
	if node2d is crossroads_object : arc.canvas.pts_calculate(0)

func _enter_tree():
	set_multiplayer_authority(int(name))

#endregion

#region inventory
func inventory_add(to_add : crossroads_item) -> bool :
	if is_reloading : return false
	var index = inventory.find(null)
	if index == -1:
		return false
	inventory[index] = to_add
	#print(index)
	arc.canvas.slots_redraw(index)
	return true

func item_hide() :
	if item == null or is_reloading : return
	item = null
	arc.canvas.weapon_redraw(arc.get_texture(""))
	arc.canvas.weapon_relabel(item)
	item_selected = -1

func item_equip(value : int) :
	if arc.is_classic and value > 1 : return
	if is_reloading : return
	item = inventory[value]
	item_selected = value
	if item == null : 
		arc.canvas.weapon_redraw(arc.get_texture(""))
		arc.canvas.weapon_relabel(null)
		item_selected = -1
		return
	else : 
		arc.canvas.weapon_redraw(item.rect)
		arc.canvas.weapon_relabel(item)

	match item.resource_name :
		"sheriff" : 
			arc.one_shot_play({"path" = "user/magnum_equip", "position" = global_position})

func item_drop() :
	if item == null or is_reloading : return
	var prefab : crossroads_object = preload("res://prefabs/objects/item.tscn").instantiate()
	get_node("/root/main/map/items").add_child(prefab)
	prefab.nbt["item"] = item
	inventory[item_selected] = null
	item = null
	item_selected = -1
	prefab.global_position = Vector2i(global_position)
	prefab.redraw()
	arc.canvas.weapon.texture.region = arc.get_texture("")
	arc.canvas.redraw()
	arc.one_shot_play({"path" = "user/drop", "type" = "2d", "position" = arc.user.global_position})

func item_reload() :
	if item == null or is_reloading : return
	is_reloading = true
	match item.resource_name :
		"nature" :
			for i in range(2) :
				arc.decal_create("shell", global_position, 0)
			arc.one_shot_play({"path" = "user/nature_load", "position" = arc.user.global_position})
			arc.one_shot_play({"path" = "user/nature_ready", "position" = arc.user.global_position, "delay" = .04})
			await get_tree().create_timer(item.nbt.get("reload", 1)).timeout
		"sheriff" :
			if item.nbt["bullets"] == 0 :
				for i in range(7) :
					arc.decal_create("bullet", global_position, 0)
				arc.one_shot_play({"path" = "user/magnum_clipout", "position" = global_position, "format" = ".wav"})
				await get_tree().create_timer(item.nbt["reload"] * 2).timeout
				arc.one_shot_play({"path" = "user/magnum_allload", "position" = arc.user.global_position})
				item.nbt["bullets"] = item.nbt["mbullets"]
				await get_tree().create_timer(item.nbt["reload"] * 2).timeout
			else :
				while item.nbt["bullets"] != item.nbt["mbullets"] :
					if item.nbt["bullets"] == item.nbt["mbullets"] : break
					arc.one_shot_play({"path" = "user/magnum_eject", "position" = global_position})
					arc.decal_create("bullet", global_position, 0)
					await get_tree().create_timer(item.nbt["reload"]).timeout
					await get_tree().create_timer(item.nbt["reload"] /2).timeout
					arc.one_shot_play({"path" = "user/magnum_load", "position" = global_position})
					item.nbt["bullets"] += 1
					await get_tree().create_timer(item.nbt["reload"]/2.3).timeout
					arc.canvas.weapon_relabel(item)
		"bucky" :
			while item.nbt["bullets"] != item.nbt["mbullets"] :
				if item.nbt["bullets"] >= item.nbt["mbullets"] : break
				arc.one_shot_play({"path" = "user/shell_load", "position" = global_position, "second" = 4.2})
				item.nbt["bullets"] += 1
				await get_tree().create_timer(item.nbt["reload"]).timeout
				arc.canvas.weapon_relabel(item)
		"1911", _ :
			arc.decal_create("magazine0", global_position, 0, 1.2)
			arc.one_shot_play({"path" = "user/reload", "position" = global_position})
			await get_tree().create_timer(item.nbt.get("reload", 1)).timeout
	item.nbt["bullets"] = item.nbt["mbullets"]
	arc.canvas.weapon_relabel(item)
	is_reloading = false
#endregion

#region input_and_actions
func INPUT( _delta) :
	if Input.is_action_just_pressed("interact") : interact_object()
	if Input.is_action_just_pressed("hide") : item_hide()
	if Input.is_action_just_pressed("attack") : attack_action()
	if Input.is_action_just_pressed("drop") : item_drop()
	if Input.is_action_just_pressed("escape") : arc.canvas.escape_redraw()
	if Input.is_action_just_pressed("reload") : 
		#reload_hold = 0
		#is_holding = true
		#if is_holding and Input.is_action_pressed("reload") :
			#reload_hold += _delta
			#if reload_hold >= 1.5 :
				#print(item.nbt["bullets"])
		#if is_holding and Input.is_action_just_released("reload") :
			#is_holding = false
		item_reload()

	if Input.is_action_just_pressed("i_0") : item_equip(0)
	if Input.is_action_just_pressed("i_1") : item_equip(1)
	if Input.is_action_just_pressed("i_2") : item_equip(2)
	if Input.is_action_just_pressed("i_3") : item_equip(3)
	if Input.is_action_just_pressed("i_4") : item_equip(4)
	if Input.is_action_just_pressed("i_5") : item_equip(5)
	#if Input.is_action_just_released("attack") : 

func attack_action() :
	if item == null or is_reloading or is_can_shoot == false : return
	var bullets = item.nbt.get("bullets", -1)
	if bullets <= 0 : 
		match item.resource_name :
			"sheriff" : arc.one_shot_play({"path" = "user/magnum_empty", "position" = global_position, "format" = ".wav"})
			"1911", _ : arc.one_shot_play({"path" = "user/empty", "position" = global_position})
		return
	is_can_shoot = false
	match item.resource_name :
		"sheriff" : arc.one_shot_play({"path" = "user/magnum", "position" = global_position, "format" = ".wav"})
		"nature" : arc.one_shot_play({"path" = "user/gun_shot", "position" = global_position})
		"bucky" : arc.one_shot_play({"path" = "user/bucky", "position" = global_position})
		"1911", _ : arc.one_shot_play({"path" = "user/gun", "position" = global_position})
	item.nbt["bullets"] -= 1
	shoot()
	arc.canvas.weapon_relabel(item)
	match item.queue :
		item.type_queue.SINGLE, item.type_queue.AUTO, item.type_queue.NONE : await get_tree().create_timer(item.nbt.get("cooldown", 1)).timeout
		#item.type_queue.SPAM : 
			#if
	is_can_shoot = true

func interact_object() :
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results = space_state.intersect_point(query)

	if results.is_empty():
		return

	var result = results[0]
	var body = result["collider"]
	var shape_index = result["shape"]

	if body is TileMapLayer : return
	var owner_id = body.shape_find_owner(shape_index)
	var shape = body.shape_owner_get_owner(owner_id)
	if global_position.distance_to(shape.global_position) > 55 : return
	if shape is crossroads_object : shape.use()

func show_light(time : float = 0) :
	light.visible = true
	await get_tree().create_timer(time).timeout
	light.visible = false

func shoot() :
	for i in item.nbt["shot"] :
		var bullet = preload("res://prefabs/entity/bullet.tscn").instantiate()
		$/root/main.add_child(bullet)
		bullet.speed = item.nbt.get("speed", 10)
		bullet.damage = item.nbt.get("damage", 1.0)
		bullet.lifetime = item.nbt.get("lifetime", 10)
		bullet.global_position = fire.global_position
		bullet.direction = Vector2(get_global_mouse_position() - global_position).normalized()
		bullet.direction.x += randf_range(-item.nbt["spread"], item.nbt["spread"])
		bullet.direction.y += randf_range(-item.nbt["spread"], item.nbt["spread"])
		bullet.direction = bullet.direction.normalized()
	show_light(.1)
	match item.resource_name :
		"bucky" : 
			await get_tree().create_timer(.12).timeout
			arc.one_shot_play({"path" = "user/shell_eject", "position" = global_position})
			arc.decal_create("shell", global_position, 0)
		"1911" : arc.decal_create("bullet", global_position, 0)

func damage(value : int = 0) : 
	if iddqd : return
	arc.canvas.hslider.value += value * 10
	if value > 0 : arc.one_shot_play({"position" = global_position, "path" ="user/power_up"})
	else : arc.one_shot_play({"position" = global_position, "path" ="user/bite"})
	if hp <= 0 : print("die")

#endregion
