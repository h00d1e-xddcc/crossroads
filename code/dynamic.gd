extends Area2D
class_name crossroads_dynamic

enum entity_type {DEFAULT, DUMMY, EXPLODE, SPAWNER, ZOMBIE, MUTANT, KAMIKADZE}

@export var nbt : Dictionary = { 
	"is_spawner" = false,
	"is_explode" = false,
	"damage" = 0,
	"time" = .7,
}
@export var hp : float = 7
@export var mhp : float = 7
@export var move : float = 170
@export var agent : NavigationAgent2D
@export var damage : int
@export var entity : entity_type
@export var is_spawner : bool
@export var is_explode : bool = false

func _ready() -> void:
	match entity : 
		entity_type.EXPLODE : explode()
		entity_type.SPAWNER :
			$sprite.queue_free()
			while true :
				await get_tree().create_timer(randi_range(3,4)).timeout
				#var roll = randi_range(0,20)
				#if roll >= 2 :
				#print("spawn")
				var _loaded_entity = load("res://prefabs/entity/default.tscn").instantiate()
				add_child(_loaded_entity)
				_loaded_entity.global_position = global_position

func _physics_process(delta: float) -> void:
	match entity :
		entity_type.ZOMBIE :
			await get_tree().create_timer(.1).timeout
			if arc.user == null : return
			else :
				agent.target_position = arc.user.global_position
			#if agent.is_navigation_finished():
				#return
			var next_point = agent.get_next_path_position()
			var direction = global_position.direction_to(next_point)
			global_position += direction * move * delta

func redraw() :
	var hpPercent = (hp - mhp) / mhp * 100
	arc.console_print(hpPercent)
	#match entity :
		#entity_type.ZOMBIE :
			#if hp == mhp : region_rect = arc.get_texture("zombie0")
			#elif hp 

func take_damage(value : float = 0) :
	#if entity == entity_type.DUMMY or entity == entity_type.SPAWNER : return
	hp -= value
	arc.user.points += int(value * 10)
	arc.one_shot_play({"path" = "user/hit", "position" = global_position})
	redraw()
	if hp >= 0 : return 
	match entity :
		entity_type.KAMIKADZE :
			arc.spawn({"summon" = "explode", "pos" = global_position})
			return
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	#print("explode " + area.name)
	match entity :
		entity_type.EXPLODE :
			match area.get_groups() :
				"infected" : take_damage(20000)
				"user" : take_damage(3)
				"explode" : area.queue_free()

func explode() :
	if is_explode == false : return
	is_explode = false
	var await_time = nbt.get("time", .4)
	var sprite : Sprite2D = $sprite
	var collision : CollisionShape2D = $collision
	collision.shape.size = Vector2(120,120)
	sprite.scale = Vector2.ONE * 2
	collision.set_deferred("disabled", true)
	sprite.texture.atlas = preload("res://pics/misc/explode.png")
	sprite.region_enabled = true
	sprite.region_rect = Rect2(64,0,64,64)
	await  get_tree().create_timer(await_time).timeout
	sprite.region_rect = Rect2(128,0,64,64)
	await  get_tree().create_timer(await_time).timeout
	entity = entity_type.EXPLODE
	collision.set_deferred("disabled", false)
	sprite.region_rect = Rect2(192,0,64,64)
	await  get_tree().create_timer(await_time).timeout
	sprite.region_rect = Rect2(256,0,64,64)
	await  get_tree().create_timer(await_time).timeout
	sprite.region_rect = Rect2(320,0,64,64)
	await  get_tree().create_timer(await_time).timeout
	sprite.region_rect = Rect2(384,0,64,64)
	await  get_tree().create_timer(await_time).timeout
	sprite.region_rect = Rect2(448,0,64,64)
	await  get_tree().create_timer(await_time).timeout
	sprite.region_rect = Rect2(0,64,64,64)
	await  get_tree().create_timer(await_time).timeout
	sprite.region_rect = Rect2(64,64,64,64)
	await  get_tree().create_timer(await_time).timeout
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	print("body" + body.name)
	match entity :
		entity_type.EXPLODE :
			if body.is_in_group("explode") : body.queue_free()
