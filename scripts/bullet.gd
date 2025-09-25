extends Area2D
 
var speed = 1000
var direction = Vector2.ZERO # Stores the direction received from the player
var bulletRotation
var bulletTime = 0.6
@onready var bulletLife = $bulletLifespan
@onready var bulletHitbox = $bulletHitbox

func _ready() -> void:
	bulletLife.start(bulletTime)

func setDirection(newDirection):
	direction = newDirection
	
func setRotation(newRotation):
	bulletRotation = newRotation
	
func _process(delta):
	if bulletLife.time_left <= 0:
		queue_free()
	# Move the bullet in the specified direction
	position += direction * speed * delta
	rotation = bulletRotation
	
func _on_bullet_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.takeDamage(10)
		queue_free()
