extends Area2D

var speed = 0.0
var damage = 0
var bullet_lifetime = 0.0
var bullet_rotation = 0.0
var direction = Vector2.ZERO
var size = 1.0
var pierce = 1

var life_timer = 0.0
var fade_ratio = 0.3 
var fade_start_time = 0.0

var trail_points = [] #New line
const TRAIL_LENGTH = 10 #New line
@onready var trail = Line2D.new() #New line

@onready var sprite = $ColorRect
@onready var bulletLife = $bulletLifespan

func _ready(): #New line
	add_child(trail) #New line
	trail.width = 3.0 #New line
	trail.default_color = Color(1, 1, 1, 0.8) #New line
	trail.gradient = Gradient.new() #New line
	trail.gradient.colors = [Color(1,1,1,0.8), Color(1,1,1,0.0)] #New line

func set_bullet_stats(new_speed, new_damage, new_lifetime, new_size, new_pierce):
	speed = new_speed
	damage = new_damage
	bullet_lifetime = new_lifetime
	pierce = new_pierce
	size = new_size
	scale = Vector2(size, size)
	
	life_timer = bullet_lifetime
	fade_start_time = bullet_lifetime * (1.0 - fade_ratio)
	bulletLife.start(bullet_lifetime)

func setDirection(newDirection):
	direction = newDirection

func setRotation(newRotation):
	bullet_rotation = newRotation

func _process(delta):
	life_timer -= delta
	var elapsed = bullet_lifetime - life_timer

	if elapsed >= fade_start_time:
		var fade_t = (elapsed - fade_start_time) / (bullet_lifetime - fade_start_time)
		fade_t = clamp(fade_t, 0.0, 1.0)
		var alpha = 1.0 - fade_t
		sprite.modulate.a = alpha
		var speed_factor = lerp(1.0, 0.3, fade_t)
		var size_factor = lerp(1.0, 0.2, fade_t)
		position += direction * (speed * speed_factor) * delta
		scale = Vector2(size, size) * size_factor
	else:
		position += direction * speed * delta

	rotation = bullet_rotation
	_update_trail() #New line

func _update_trail(): #New line
	trail_points.push_front(global_position)
	if trail_points.size() > TRAIL_LENGTH:
		trail_points.pop_back()
	trail.points = trail_points

func _on_bullet_lifespan_timeout() -> void:
	queue_free()

func _on_bullet_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.takeDamage(damage)
		pierce -= 1
		if pierce <= 0:
			queue_free()
