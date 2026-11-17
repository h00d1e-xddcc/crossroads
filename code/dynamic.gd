extends Area2D
class_name crossroads_dynamic

enum entity_type {DEFAULT, DUMMY, EXPLODE, SPAWNER, ZOMBIE, MUTANT, KAMIKADZE, WALL,
ACID, SPITTER}

@export var nbt : Dictionary = { 
	"is_spawner" = false,
	"is_explode" = false,
	"is_enabled" = true,
	"is_acid" = false,
	"has_acid" = false,
	"damage" = 0,
	"time" = .7,
	"entity" = "none",
}
@export var hp : float = 7
@export var mhp : float = 7
@export var move : float = 170
@export var agent : NavigationAgent2D
@export var damage : int
@export var entity : entity_type

func _ready() -> void:
	if !nbt.get("is_enabled", false) : return
	match entity : 
		entity_type.EXPLODE : explode()
		entity_type.ACID : acid()
		entity_type.SPAWNER :
			$sprite.queue_free()
			while true :
				await get_tree().create_timer(randi_range(3,10)).timeout
				spawn()

func _physics_process(delta: float) -> void:
	match entity :
		entity_type.ZOMBIE, entity_type.KAMIKADZE, entity_type.SPITTER :
			await get_tree().create_timer(.1).timeout
			if arc.user == null : 
				print("return")
				return
			else :
				agent.target_position = arc.user.global_position
			#if agent.is_navigation_finished():
				#return
			var next_position = agent.get_next_path_position()
			var direction = global_position.direction_to(next_position)

			global_position += direction * (move / 3) * delta


func redraw() :
	var hpPercent = (hp - mhp) / mhp * 100
	arc.console_print(hpPercent)
	#match entity :
		#entity_type.ZOMBIE :
			#if hp == mhp : region_rect = arc.get_texture("zombie0")
			#elif hp 

func take_damage(value : float = 0) :
	match entity : 
		entity_type.SPITTER :
			arc.summon_entity("acid", global_position)
			nbt.set("has_acid", false)
			entity = entity_type.ZOMBIE
			$sprite.region_rect = arc.get_texture("default")
		entity_type.KAMIKADZE : 
			arc.summon_entity("explode", global_position)
			queue_free()
	hp -= value
	arc.user.points += int(value * 10)
	arc.one_shot_play({"path" = "user/hit", "position" = global_position})
	redraw()
	if hp >= 0 : return 
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	#print("body" + body.name)
	match entity :
		entity_type.EXPLODE :
			if body.is_in_group("explode") : body.get_parent().queue_free()
	if body.is_in_group("user") : body.damage(nbt.get("damage", 1))

func _on_area_entered(area: Area2D) -> void:
	#print("explode " + area.name)
	match entity :
		entity_type.WALL :
			if area.is_in_group("explode") : queue_free()
		entity_type.EXPLODE :
			match area.get_groups() :
				"infected" : take_damage(20000)
				"user" : take_damage(3)
	if area == crossroads_user : take_damage(1)

func spawn() :
	var roll = randi_range(0,100)
	if roll > 85  : 
		arc.summon_entity("spitter", global_position)
		return
	if roll > 70 :
		arc.summon_entity("kamikadze", global_position)
		return
	if roll > 30 :
		arc.summon_entity("default", global_position)

func explode() :
	if !nbt.get("is_explode", false) : return
	nbt.set("is_explode", false)
	var await_time = nbt.get("time", 1)
	var sprite : AnimatedSprite2D = $sprite
	sprite.play("default")
	sprite.connect("animation_finished", queue_free)
	#await  get_tree().create_timer(await_time).timeout
	#queue_free()

func acid() :
	if !nbt.get("is_acid", false) : return
	nbt.set("is_acid", false)
	var await_time = nbt.get("time", 1)
	var sprite : AnimatedSprite2D = $sprite
	sprite.play()
	await  get_tree().create_timer(await_time).timeout
	queue_free()
