extends Area2D

# MOVEMENT/KNOCKBACK VARIABLES
var playerDirection = Vector2.ZERO
var speed = Global.enemySpeed * 0.5 
var health = Global.enemyHP * 0.75 
var knockback_vector = Vector2.ZERO
var knockback_timer = 0.0
const KNOCKBACK_DURATION = 0.15
const MIN_SHOOTING_DISTANCE = 200

# SHOOTER VARIABLES
@onready var player = get_tree().get_root().find_child("Player", true, false)
@onready var fireTimer = $FireTimer 
@onready var Muzzle = $Muzzle
@onready var death_particles_scene = preload("res://scenes/death_particles.tscn")
@onready var enemy_projectile = preload("res://scenes/projectiles/enemy_projectile.tscn")
const FIRE_RATE = 2.0 
const PROJECTILE_SPEED = 300

func _ready():
	Global.increaseEnemyCount()
	fireTimer.wait_time = FIRE_RATE
	fireTimer.stop()

func _xp_popup(xp_amount):
	var popup = preload("res://scenes/xp_popup.tscn").instantiate()
	popup.text = "+%d XP" % xp_amount #replace with actual xp amt
	popup.global_position = global_position
	get_tree().current_scene.add_child(popup)

func enemyDied():
	UI_Global.add_shake(0.2)
	AudioGlobal.play_death()
	Global.decrease_enemy_count()
	Global.addXP(50)
	Global.emit_signal("xp_changed", 50)
	
	_xp_popup(50)
	
	var particles = death_particles_scene.instantiate()
	particles.global_position = global_position
	particles.modulate = Color(1.0, 0.267, 0.0, 1.0)
	get_tree().current_scene.add_child(particles)
	particles.emitting = true
	queue_free()

func takeDamage(damageAmount):
	AudioGlobal.play_hurt()
	health -= damageAmount
	if health <= 0:
		enemyDied()

func apply_knockback(direction_vector: Vector2, force: float):
	knockback_vector = direction_vector * force
	knockback_timer = KNOCKBACK_DURATION 

func _process(delta: float) -> void:
	if is_instance_valid(player):
		look_at(player.global_position)
		
	if knockback_timer > 0:
		# ... (knockback logic remains the same) ...
		global_position += knockback_vector * delta
		knockback_vector = lerp(knockback_vector, Vector2.ZERO, 15.0 * delta)
		knockback_timer -= delta
		if knockback_timer <= 0:
			knockback_vector = Vector2.ZERO
	else:
		if is_instance_valid(player):
			var distance_to_player = global_position.distance_to(player.global_position)
			
			if distance_to_player > MIN_SHOOTING_DISTANCE:
				#movement zone
				playerDirection = (player.global_position - global_position).normalized()
				global_position += playerDirection * speed * delta
				fireTimer.stop()
			else:
				#shooting zone
				playerDirection = Vector2.ZERO 
				if fireTimer.is_stopped(): 
					fireTimer.start()
		else:
			queue_free()

func _on_fire_timer_timeout():
	if is_instance_valid(player):
		var projectile = enemy_projectile.instantiate()
		get_tree().root.add_child(projectile)
		var shoot_direction = (player.global_position - Muzzle.global_position).normalized()
		projectile.global_position = Muzzle.global_position
		projectile.set_velocity(shoot_direction * PROJECTILE_SPEED)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"): #literally never gonna happen buuuut yk
		body.takeDamage(50) 
		queue_free()
