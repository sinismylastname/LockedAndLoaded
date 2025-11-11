extends Area2D

var playerDirection = Vector2.ZERO
var speed = Global.enemySpeed
var health = Global.enemyHP
var max_health = Global.enemyHP 
var knockback_vector = Vector2.ZERO
var knockback_timer = 0.0
const KNOCKBACK_DURATION = 0.15
var player = null
var offscreen_speed_multiplier = 6.0
var particle_color = Color(4.0, 0.027, 0.086)
var body_color_1 = Color(4.0, 0.027, 0.086)
var body_color_2 =Color(0.506, 0.0, 0.02)
var is_visible_to_camera = false
@onready var death_particles_scene = preload("res://scenes/death_particles.tscn")
@onready var hit_particles_scene = preload("res://scenes/hit_particles.tscn") 
@onready var visibility = $VisibilityNotifier


func apply_knockback(direction_vector: Vector2, force: float):
	knockback_vector = direction_vector * force
	knockback_timer = KNOCKBACK_DURATION 

func _ready():
	Global.increaseEnemyCount()
	Global.connect("player_changed", Callable(self, "_on_player_changed"))
	_on_player_changed(Global.Player)
	visibility.connect("screen_entered", Callable(self, "_on_screen_entered"))
	visibility.connect("screen_exited", Callable(self, "_on_screen_exited"))

func _on_screen_entered():
	is_visible_to_camera = true

func _on_screen_exited():
	is_visible_to_camera = false

func _on_player_changed(new_player):
	player = new_player

func _xp_popup(xp_amount):
	var popup = preload("res://scenes/xp_popup.tscn").instantiate()
	popup.text = "+%d XP" % xp_amount
	popup.global_position = global_position
	get_tree().current_scene.add_child(popup)

func flash_on_hit():
	var t = create_tween()
	modulate = Color(2, 2, 2)
	t.tween_property(self, "modulate", Color(1, 1, 1), 0.1)

func _enemy_death_particles():
	var particles = death_particles_scene.instantiate()
	particles.global_position = global_position
	particles.modulate = particle_color
	get_tree().current_scene.add_child(particles)
	particles.emitting = true

func enemyDied():
	Global.decrease_enemy_count()
	AudioGlobal.play_death()
	Global.addXP(25)
	Global.emit_signal("xp_changed", 25)
	_xp_popup(25)
	UI_Global.add_shake(0.3)
	_enemy_death_particles()
	queue_free()

func takeDamage(damageAmount, hit_direction: Vector2 = Vector2.ZERO, hit_position: Vector2 = Vector2.ZERO):
	if not is_inside_tree():
		return
	flash_on_hit()
	AudioGlobal.play_hurt()
	UI_Global.add_shake(0.2)
	health -= damageAmount

	if hit_direction == Vector2.ZERO:
		if hit_position != null:
			hit_direction = (hit_position - global_position).normalized()
		elif is_instance_valid(player):
			hit_direction = (global_position - player.global_position).normalized()
	if hit_direction != Vector2.ZERO:
		hit_direction = hit_direction.normalized()

	if health <= 0:
		if is_inside_tree():
			enemyDied()
	else:
		var hit = hit_particles_scene.instantiate()
		hit.global_position = global_position
		get_tree().current_scene.add_child(hit)
		hit.one_shot = true
		if "modulate" in hit:
			hit.modulate = particle_color
		hit.emitting = true
		print(hit_direction)

func _process(delta: float) -> void:
	if knockback_timer > 0:
		global_position += knockback_vector * delta
		knockback_vector = lerp(knockback_vector, Vector2.ZERO, 15.0 * delta)
		knockback_timer -= delta
		if knockback_timer <= 0:
			knockback_vector = Vector2.ZERO 
	elif knockback_timer <= 0:
		if is_instance_valid(player):
			playerDirection = (player.global_position - global_position).normalized()
			var move_speed = speed
			if not is_visible_to_camera:
				move_speed *= offscreen_speed_multiplier
			global_position += playerDirection * move_speed * delta
			look_at(player.global_position)
	else:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.takeDamage(25)
		Global.decrease_enemy_count()
		queue_free()
