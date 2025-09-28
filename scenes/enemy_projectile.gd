extends Area2D

var velocity = Vector2.ZERO
const LIFESPAN = 3.0
var timer = 0.0
@onready var player = get_tree().get_root().find_child("Player", true, false)

func set_velocity(new_velocity: Vector2):
	velocity = new_velocity
	look_at(global_position + velocity)

func _ready():
	pass

func _process(delta: float) -> void:
	global_position += velocity * delta
	
	timer += delta
	if timer >= LIFESPAN:
		queue_free()

func _on_area_entered(area: Area2D):
	if area.is_in_group("shield"):
		queue_free() 
		
func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.takeDamage(10)
		queue_free()
