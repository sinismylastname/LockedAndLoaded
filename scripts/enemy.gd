extends Area2D

var playerDirection = Vector2.ZERO
var speed = Global.enemySpeed
var health = Global.enemyHP
var knockback_vector = Vector2.ZERO
var knockback_timer = 0.0
const KNOCKBACK_DURATION = 0.15
var player = null
var offscreen_speed_multiplier = 6.0
var is_visible_to_camera = false
@onready var death_particles_scene = preload("res://scenes/death_particles.tscn")
@onready var visibility = $VisibilityNotifier


func apply_knockback(direction_vector: Vector2, force: float):
	knockback_vector = direction_vector * force
	knockback_timer = KNOCKBACK_DURATION 

func _ready():
	Global.increaseEnemyCount()
	Global.connect("player_changed", Callable(self, "_on_player_changed"))
	_on_player_changed(Global.Player) # initialize immediately
	
	visibility.connect("screen_entered", Callable(self, "_on_screen_entered"))
	visibility.connect("screen_exited", Callable(self, "_on_screen_exited"))


func _on_screen_entered():
	is_visible_to_camera = true


func _on_screen_exited():
	is_visible_to_camera = false
	

func _on_player_changed(new_player):
	player = new_player

func enemyDied():
	UI_Global.add_shake(0.2)
	AudioGlobal.play_death()
	Global.decrease_enemy_count()
	Global.addXP(25)
	Global.emit_signal("xp_changed", 25)
	
	var particles = death_particles_scene.instantiate()
	particles.global_position = global_position
	particles.modulate = Color(0.965, 0.0, 0.0, 1.0)
	get_tree().current_scene.add_child(particles)
	particles.emitting = true
	queue_free()

func takeDamage(damageAmount):
	if !is_inside_tree(): 
		return
	AudioGlobal.play_hurt()
	UI_Global.add_shake(0.1)
	health -= damageAmount
	if health <= 0 and is_inside_tree():
		enemyDied()

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
