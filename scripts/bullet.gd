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

var trail_points := []
const TRAIL_LENGTH := 12

@onready var sprite = $ColorRect
@onready var bulletLife = $bulletLifespan
var trail: Line2D = null

func _ready():
	trail = Line2D.new()
	get_tree().current_scene.add_child(trail)
	trail.width = 3.0
	trail.default_color = Color(1, 1, 1, 0.85)

func set_bullet_stats(new_speed, new_damage, new_lifetime, new_size, new_pierce):
	speed = new_speed
	damage = new_damage
	bullet_lifetime = new_lifetime
	pierce = new_pierce
	size = new_size
	trail.width = new_size * 3 #bullet trail size
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
		global_position += direction * (speed * speed_factor) * delta
		scale = Vector2(size, size) * size_factor
	else:
		global_position += direction * speed * delta

	rotation = bullet_rotation
	_update_trail()

func _update_trail():
	trail_points.push_back(global_position)
	if trail_points.size() > TRAIL_LENGTH:
		trail_points.pop_front()
	var out := PackedVector2Array()
	for p in trail_points:
		out.append(p)
	trail.points = out
	trail.global_position = Vector2.ZERO

func _on_bullet_lifespan_timeout() -> void:
	set_process(false)
	await _fade_trail() 
	queue_free() 

func _fade_trail():
	var fade_time := 0.3
	var fade_timer := 0.0
	var start_color := trail.default_color
	
	while fade_timer < fade_time:
		fade_timer += get_process_delta_time()
		var t := clampf(fade_timer / fade_time, 0.0, 1.0)
		trail.default_color.a = lerp(start_color.a, 0.0, t)
		
		if trail_points.size() > 0:
			trail_points.pop_front()
			trail.points = PackedVector2Array(trail_points)
		
		await get_tree().process_frame
	
	if is_instance_valid(trail):
		trail.queue_free()


func _on_bullet_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.takeDamage(damage)
		pierce -= 1
		if pierce <= 0:
			if is_instance_valid(trail):
				trail.queue_free()
			queue_free()
