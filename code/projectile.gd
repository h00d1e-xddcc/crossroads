extends Area2D
class_name  crossroads_projectile

enum type_projectile {NONE, BULLET, ARROW}

@export var speed : float = 10
@export var damage : float = 1.0
@export var lifetime : float = 5.7
@export var type : type_projectile
@export var durability : int = 0
var direction : Vector2 = Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	
func set_direction(value : Vector2) -> void:
	direction = value.normalized()

func pof() :
	$collider.queue_free()
	direction = Vector2.ZERO * 100
	var sprite = $sprite
	sprite.texture = sprite.texture.duplicate()
	sprite.texture.region = Rect2 (1216, 2017, 32, 32)
	for i in range(5) :
		await get_tree().create_timer(.12).timeout
		sprite.texture.region.position.y -= 32
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	match body.name :
		"hole", "decor", "projectile", "user" : return
	durability -= 1
	if durability <= 0 : pof()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
		durability -= 1
		if durability <= 0 : pof()
