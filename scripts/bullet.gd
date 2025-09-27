# bullet.gd
extends Area2D
 
var speed = 0.0
var damage = 0
var bullet_lifetime = 0.0 
var bullet_rotation = 0.0
var direction = Vector2.ZERO 
var size = 1.0 
var pierce = 1

@onready var bulletLife = $bulletLifespan

# --- FIX: New function to receive all stats from the Player ---
func set_bullet_stats(new_speed, new_damage, new_lifetime, new_size, new_pierce):
	speed = new_speed
	damage = new_damage
	bullet_lifetime = new_lifetime
	pierce = new_pierce
	scale = Vector2(new_size, new_size) 

func _ready() -> void:
	bulletLife.start(bullet_lifetime)

func setDirection(newDirection):
	direction = newDirection
	
func setRotation(newRotation):
	bullet_rotation = newRotation 

func _process(delta):
	position += direction * speed * delta
	rotation = bullet_rotation

func _on_bullet_lifespan_timeout() -> void:
	queue_free()

func _on_bullet_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.takeDamage(damage)
		pierce -= 1
		if pierce <= 0:
			queue_free()
