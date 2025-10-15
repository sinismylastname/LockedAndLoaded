extends Area2D
 
var speed = 0.0
var damage = 0
var beam_lifetime = 0.0 
var beam_rotation = 0.0
var direction = Vector2.ZERO 
var size = 1.0 
var pierce = 1
var time_alive = 0.0

@onready var beam_life = $BeamLifespan
@onready var sprite = $ColorRect

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
	var t = 1.0 - (beam_life.time_left / beam_lifetime)
	sprite.modulate.a = 1.0 - t

func _on_beam_lifespan_timeout() -> void:
	time_alive = 0.0
	call_deferred("queue_free")

func _on_beam_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.takeDamage(damage)
		pierce -= 1
		if pierce <= 0:
			call_deferred("queue_free")
