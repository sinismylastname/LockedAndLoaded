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
	var width_curve := Curve.new()
	width_curve.add_point(Vector2(0, 0))
	width_curve.add_point(Vector2(1, clamp(size * 0.8, 0.8, 1.5)))
	trail.width_curve = width_curve
	get_tree().current_scene.add_child(trail)
	trail.width = 3.0
	trail.default_color = Color(1, 1, 1, 0.85)
	# start tiny; actual grow tween happens in set_bullet_stats
	scale = Vector2(0.1, 0.1)

func set_bullet_stats(new_speed, new_damage, new_lifetime, new_size, new_pierce):
	speed = new_speed
	damage = new_damage
	bullet_lifetime = new_lifetime
	pierce = new_pierce
	size = new_size

	# trail width follows size
	trail.width = max(1.0, size * 3)
	life_timer = bullet_lifetime
	fade_start_time = bullet_lifetime * (1.0 - fade_ratio)
	bulletLife.start(bullet_lifetime)

	# spawn pop: start small -> grow to intended size quickly
	scale = Vector2(size * 0.1, size * 0.1)
	var t = create_tween()
	t.tween_property(self, "scale", Vector2(size, size), 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func setDirection(newDirection):
	direction = newDirection

func setRotation(newRotation):
	bullet_rotation = newRotation

func _process(delta):
	life_timer -= delta
	var elapsed = bullet_lifetime - life_timer

	# fade near end
	if elapsed >= fade_start_time:
		var fade_t = (elapsed - fade_start_time) / (bullet_lifetime - fade_start_time)
		fade_t = clamp(fade_t, 0.0, 1.0)
		var alpha = 1.0 - fade_t
		sprite.modulate.a = alpha
		# trail global alpha: multiply default alpha
		trail.default_color.a = alpha
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

	# build points array (use global coords) and a gradient so tail is transparent -> head opaque
	var out := PackedVector2Array()
	var n := trail_points.size()
	for p in trail_points:
		out.append(p)
	trail.points = out
	trail.global_position = Vector2.ZERO

	# build gradient normalized by actual trail length
	if n > 0:
		var grad := Gradient.new()
		# avoid degenerate denom
		var denom := maxi(1, n - 1)
		for i in range(n):
			var offset := float(i) / float(denom) # 0 = oldest, 1 = newest
			var alpha := offset # tail (0) transparent -> head (1) opaque
			var c := Color(1, 1, 1, clamp(alpha, 0.0, 1.0))
			grad.add_point(offset, c)
		trail.gradient = grad

func _on_bullet_lifespan_timeout() -> void:
	set_process(false)
	await _fade_trail()
	queue_free()

func _fade_trail():
	var fade_time := 0.3
	var fade_timer := 0.0
	var start_alpha := trail.default_color.a
	while fade_timer < fade_time:
		fade_timer += get_process_delta_time()
		var t := clampf(fade_timer / fade_time, 0.0, 1.0)
		# fade overall alpha
		var a = lerp(start_alpha, 0.0, t)
		trail.default_color.a = a
		# shorten trail gradually
		if trail_points.size() > 0:
			trail_points.pop_front()
			trail.points = PackedVector2Array(trail_points)
			# rebuild gradient to match new length
			var n := trail_points.size()
			if n > 0:
				var grad = Gradient.new()
				var denom = maxi(1, n - 1)
				for i in range(n):
					var offset = float(i) / float(denom)
					var alpha = offset * a
					grad.add_point(offset, Color(1, 1, 1, clamp(alpha, 0.0, 1.0)))
				trail.gradient = grad
		await get_tree().process_frame
	if is_instance_valid(trail):
		trail.queue_free()

func _on_bullet_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.takeDamage(damage)
		pierce -= 1
		if pierce <= 0:
			# let fade coroutine handle fading when lifespan ends; keep consistent here
			if is_instance_valid(trail):
				trail.queue_free()
			queue_free()
