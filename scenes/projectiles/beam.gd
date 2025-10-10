extends Area2D
 
var speed = 0.0
var damage = 0
var beam_lifetime = 0.0 
var beam_rotation = 0.0
var direction = Vector2.ZERO 
var size = 1.0 
var pierce = 1

@onready var beam_life = $BeamLifespan

func set_bullet_stats(new_damage, new_lifetime, new_pierce):
	damage = new_damage
	beam_lifetime = new_lifetime
	pierce = new_pierce

func _ready() -> void:
	beam_life.start(beam_lifetime)

func setDirection(newDirection):
	direction = newDirection
	
func setRotation(newRotation):
	beam_rotation = newRotation 

func _process(delta):
	rotation = beam_rotation

func _on_bullet_lifespan_timeout() -> void:
	call_deferred("queue_free")

func _on_bullet_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.takeDamage(damage)
		pierce -= 1
		if pierce <= 0:
			call_deferred("queue_free")
