extends Area2D

var playerDirection = Vector2.ZERO
var speed = 50
var health = 10
@onready var player = get_tree().get_root().find_child("Player", true, false)

func takeDamage(damageAmount):
	health -= damageAmount
	print(health )
	if health <= 0:
		queue_free()
		
func _process(delta: float) -> void:
		if is_instance_valid(player):
			playerDirection = (player.global_position - global_position).normalized()
			global_position += playerDirection * speed * delta
			look_at(player.global_position)
		else:
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.takeDamage(50)
		queue_free()
