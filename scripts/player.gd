extends CharacterBody2D

const SWAP_TIMEOUT = 0.2
var last_space_press_time = 0.0

var rotationAccel = 5.0
var currentRotationSpeed = 0.0
var rotation_accel = 6.0
var rotation_decel = 12.0
var max_rotation_speed = 6.0
var rotation_speed = 0.0
var input_direction = Vector2.ZERO
var projectile = preload("res://scenes/projectiles/bullet.tscn")

var finalFireRate
var finalBulletSpeed
var finalHealth
var finalDamage
var finalBulletPierce
var finalRotationSpeed
var finalBulletLifetime
var finalBulletSize
var finalAimAssist
var currentHealth = 0.0

const baseFireRate = 1.0
const baseFireRateReduction = 0.8
const baseBulletSpeed = 500
const baseSpeedAddition = 125
const baseBulletDamage = 10
const baseHealth = 100
const baseHealthAddition = 75
const baseDamage = 10
const baseDamageAddition = 10
const basePierce = 1
const basePierceAddition = 1
const baseRotationSpeed = 2
const baseRotationSpeedAddition = 1
const baseBulletLifetime = 0.5
const baseBulletLifetimeAddition = 0.05
const baseBulletSize = 1
const baseBulletSizeAddition = 0.5
const AIM_ASSIST_RANGE = 800
const AIM_ASSIST_STRENGTH = 0.7
const AIM_CONE_ANGLE = PI / 16.0

#changed calculations to account for the reduction in points

var parry_active = false
var parry_on_cooldown = false
var parried = true
const PARRY_WINDOW = 0.15
const PARRY_COOLDOWN = 1.5

signal fireRateChanged(newFiringRate)
signal cooldownUpdated
signal healthUpdated
signal playerDied
signal parried_signal

@onready var fireTimer = $FireTimer
@onready var invincTimer = $InvincibilityTimer
@onready var playerAnimator = $Animator
@onready var parry_hitbox = $ParryHitbox
@onready var TP_Point = get_tree().current_scene.get_node_or_null("TPPoint")
@onready var level_up_particles = $LevelUpParticles
@onready var parry_ready_particles = $ParryReadyParticle



func _ready() -> void:
	update_stats()
	process_mode = Node.PROCESS_MODE_ALWAYS
	currentHealth = finalHealth
	$ParryCircle.visible = false
	Global.connect("leveled_up", Callable(self, "_level_up_vfx"))
	
	
func update_stats():
	var fire_level = Global.upgrades["fire_rate_level"]
	finalFireRate = baseFireRate - (fire_level * baseFireRateReduction)
	
	emit_signal("fireRateChanged", fireTimer.wait_time)
	
	var range_level = Global.upgrades["bullet_range_level"]
	finalBulletSpeed = baseBulletSpeed + (range_level * baseSpeedAddition)
	finalBulletLifetime = baseBulletLifetime + (range_level * baseBulletLifetimeAddition)
	
	var health_level = Global.upgrades["health_level"]
	finalHealth = baseHealth + (health_level * baseHealthAddition)
	
	var power_level = Global.upgrades["bullet_power_level"]
	finalDamage = baseDamage + (power_level * baseDamageAddition)
	finalBulletSize = baseBulletSize + (power_level * baseBulletSizeAddition)
	
	var pierce_level = Global.upgrades["bullet_pierce_level"]
	finalBulletPierce = basePierce + (pierce_level * basePierceAddition)
	
	var rotation_level = Global.upgrades["rotation_speed_level"]
	finalRotationSpeed = baseRotationSpeed + (rotation_level * baseRotationSpeedAddition)
	
	apply_class_modifiers()
	fireTimer.wait_time = max(0.020, finalFireRate) #ok my fireTimer line is here because the class modifiers break the hell out of it
	emit_signal("healthUpdated", currentHealth)


func apply_class_modifiers():
	# Placeholder; subclasses override this.
	pass

func takeDamage(damageAmount):
	AudioGlobal.play_hurt()
	if not parry_active: 
		currentHealth -= damageAmount
	elif parry_active:
		print("holy crap you just parried")
	if currentHealth <= 0:
		emit_signal("playerDied")
		print("player died.")
		AudioGlobal.play_death()
		queue_free()
	emit_signal("healthUpdated", currentHealth)
		

func _level_up_vfx():
	level_up_particles.restart()
	level_up_particles.emitting = true
	print("emitted!!")
	UI_Global.add_shake(0.3)
	
	

func get_closest_target() -> Node2D:
	var closest_target: Node2D = null
	var min_distance = AIM_ASSIST_RANGE
	var player_direction = Vector2.RIGHT.rotated(rotation).normalized() 
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance < min_distance:
				var to_enemy_vector = (enemy.global_position - global_position).normalized()
				if player_direction.dot(to_enemy_vector) >= cos(AIM_CONE_ANGLE):
					min_distance = distance
					closest_target = enemy
	return closest_target

func fireProjectile():
	playerAnimator.play("fire")
	AudioGlobal.play_default_shoot_sound()
	var projectile = projectile.instantiate()
	projectile.setRotation(rotation)
	get_tree().root.add_child(projectile)
	UI_Global.add_shake(finalDamage/100)
	
	projectile.set_bullet_stats(
		finalBulletSpeed, 
		finalDamage, 
		finalBulletLifetime, 
		finalBulletSize,
		finalBulletPierce
	)
	
	var muzzle = $FrontMuzzle
	projectile.global_position = muzzle.global_position
	
	var directionVector = Vector2.RIGHT.rotated(rotation)
	projectile.setDirection(directionVector)
	

	
func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("parry"):
		_start_parry()
	
	if event.is_action_pressed("teleport") and Global.tp_point_array.size() > 0:
		teleport_to_point()

func teleport_to_point():
	if Global.tp_point_array.size() == 0:
		return

	Global.current_tp_index = (Global.current_tp_index + 1) % Global.tp_point_array.size()
	Global.next_tp_point = Global.tp_point_array[Global.current_tp_index]

	# Teleport the player
	global_position = Global.next_tp_point.global_position


func _start_parry():
	if parry_on_cooldown:
		return

	parry_active = true
	parry_on_cooldown = true
	parried = false 
	print("PARRY ACTIVE")
	parry_hitbox.monitoring = true
	$ParryCircle.visible = true
	
	await get_tree().create_timer(PARRY_WINDOW).timeout
	
	parry_active = false
	parry_hitbox.monitoring = false
	print("PARRY ENDED")
	$ParryCircle.visible = false
	
	if parried:
		parry_on_cooldown = false
		print("PARRY SUCCESS – READY AGAIN")
		_show_parry_ready_pulse()
	else:
		await get_tree().create_timer(PARRY_COOLDOWN).timeout
		parry_on_cooldown = false
		print("PARRY MISSED – COOLDOWN DONE")
		_show_parry_ready_pulse()
	
func _show_parry_ready_pulse():
	parry_ready_particles.restart()
	parry_ready_particles.emitting
	
func _on_parry_hitbox_area_entered(area: Area2D) -> void:
	if parry_active and area.is_in_group("enemies"):
		if area.has_method("apply_knockback"):
			area.apply_knockback(global_position.direction_to(area.global_position), 3000)
			#parried.emit()
			parry_vfx()
			AudioGlobal.play_parry() #holy crap im a frickin genius bro parrying is so cool LOOL WOWIE ZOWIE
			parried = true
	elif parry_active and area.is_in_group("enemy_projectiles"):
		area.reverse_direction() 

func parry_vfx():
	var flash = ColorRect.new()
	flash.color = Color(0.882, 0.835, 0.624, 0.204)
	flash.size = get_viewport_rect().size
	get_tree().current_scene.add_child(flash)
	await get_tree().create_timer(0.05).timeout
	Engine.time_scale = 0.005
	await get_tree().create_timer(0.001, true).timeout
	Engine.time_scale = 1.0
	flash.queue_free()
	UI_Global.add_shake(0.1)

func _on_fire_timer_timeout() -> void:
	fireProjectile()

func apply_health_upgrade():
	var old_max_health = finalHealth 
	update_stats() 
	
	var health_gain = finalHealth - old_max_health
	currentHealth += health_gain 
	currentHealth = min(currentHealth, finalHealth)
	emit_signal("healthUpdated", currentHealth)

func get_state() -> Dictionary:
	return {
		"health": currentHealth,
		"upgrades": Global.upgrades.duplicate(true),
		"position": global_position,
		"rotation": rotation
	}

func apply_state(state: Dictionary):
	if state.has("health"):
		currentHealth = state["health"]
	if state.has("upgrade"):
		Global.upgrades = state["upgrades"].duplicate(true)
	if state.has("position"):
		global_position = state["position"]
	if state.has("rotation"):
		rotation = state["rotation"]
	

func _process(delta):
	if get_tree().is_paused():
		return

	input_direction = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")

	if input_direction.length() > 0:
		var target_angle = input_direction.angle()
		var angle_diff = wrapf(target_angle - rotation, -PI, PI)
		currentRotationSpeed += rotationAccel * delta
		currentRotationSpeed = minf(currentRotationSpeed, finalRotationSpeed)
		rotation += clampf(angle_diff, -currentRotationSpeed * delta, currentRotationSpeed * delta)
	else:
		currentRotationSpeed = lerpf(currentRotationSpeed, 0.0, rotationAccel * delta)

	var target = get_closest_target()
	if input_direction.length() == 0 and is_instance_valid(target):
		var target_dir = (target.global_position - global_position).normalized()
		var target_angle = target_dir.angle()
		var angle_diff = wrapf(target_angle - rotation, -PI, PI)
		rotation += angle_diff * finalRotationSpeed * AIM_ASSIST_STRENGTH * delta

	emit_signal("cooldownUpdated", fireTimer.time_left)
	emit_signal("healthUpdated", currentHealth)
		
	
