extends Area2D
class_name crossroads_entity

enum entity_type {DEFAULT, DUMMY, SPAWNER, ZOMBIE, MUTANT}

@export var hp : float = 7
@export var mhp : float = 7
@export var damage : int
@export var entity : entity_type

func _ready() -> void:
	match entity :
		entity_type.SPAWNER :
			$zombie.queue_free()
			$collision.queue_free()
			while true :
				var roll = randi_range(0,20)
				await get_tree().create_timer(randi_range(3,10)).timeout
				if roll >= 2 :
					var entity = preload("res://prefabs/entity/zombie.tscn").instantiate()
					add_child(entity)
					entity.global_position = global_position

func redraw() :
	var hpPercent = (hp - mhp) / mhp * 100
	arc.console_print(hpPercent)
	#match entity :
		#entity_type.ZOMBIE :
			#if hp == mhp : region_rect = arc.get_texture("zombie0")
			#elif hp 

func take_damage(value : float = 0) :
	if entity == entity_type.DUMMY or entity == entity_type.SPAWNER : return
	hp -= value
	arc.user.points += int(value * 10)
	arc.one_shot_play({"path" = "user/hit", "position" = global_position})
	redraw()
	if hp <= 0 : queue_free()
