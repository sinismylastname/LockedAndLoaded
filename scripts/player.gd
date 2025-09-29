extends CharacterBody2D

enum Tool { BLASTER, SHIELD }
var active_tool = Tool.BLASTER
const SWAP_TIMEOUT = 0.25
var last_space_press_time = 0.0

var rDir = 1
var lastDir
var rotationAccel = 15.0
var currentRotationSpeed = 0.0
var iFrameSeconds = 0.5
var bullet = preload("res://scenes/bullet.tscn")

var finalFireRate
var finalBulletSpeed
var finalHealth
var finalDamage
var finalBulletPierce
var finalRotationSpeed
var finalBulletLifetime
var finalBulletSize
var currentHealth = 0.0

const baseFireRate = 1.0
const baseFireRateReduction = 0.020
const baseBulletSpeed = 500
const baseSpeedAddition = 50
const baseBulletDamage = 10
const baseHealth = 100
const baseHealthAddition = 10
const baseDamage = 10
const baseDamageAddition = 2.5
const basePierce = 0
const basePierceAddition = 1
const baseRotationSpeed = 2
const baseRotationSpeedAddition = 0.5
const baseBulletLifetime = 0.5
const baseBulletLifetimeAddition = 0.25
const baseBulletSize = 1
const baseBulletSizeAddition = 0.2
const AIM_ASSIST_RANGE = 300
const AIM_ASSIST_STRENGTH = 0.5
const AIM_CONE_ANGLE = PI / 16.0

signal fireRateChanged(newFiringRate)
signal cooldownUpdated
signal healthUpdated
signal playerDied

@onready var fireTimer = $FireTimer
@onready var invincTimer = $InvincibilityTimer
@onready var playerAnimator = $Animator

func update_stats():
	var fire_level = Global.upgrades["fire_rate_level"] #1
	finalFireRate = baseFireRate - (fire_level * baseFireRateReduction)
	fireTimer.wait_time = max(0.020, finalFireRate)
	emit_signal("fireRateChanged", fireTimer.wait_time)
	
	var range_level = Global.upgrades["bullet_range_level"] #2
	finalBulletSpeed = baseBulletSpeed + (range_level * baseSpeedAddition)
	finalBulletLifetime = baseBulletLifetime + (range_level * baseBulletLifetimeAddition)
	
	var health_level = Global.upgrades["health_level"]#3
	finalHealth = baseHealth + (health_level * baseHealthAddition)
	
	var power_level = Global.upgrades["bullet_power_level"] #4
	finalDamage = baseDamage + (power_level * baseDamageAddition)
	finalBulletSize = baseBulletSize + (power_level * baseBulletSizeAddition)
	
	var pierce_level = Global.upgrades["bullet_pierce_level"] #5
	finalBulletPierce = basePierce + (pierce_level * basePierceAddition)
	
	var rotation_level = Global.upgrades["rotation_speed_level"] #6
	finalRotationSpeed = baseRotationSpeed + (rotation_level * baseRotationSpeedAddition)
	
	emit_signal("healthUpdated", currentHealth)

func takeDamage(damageAmount):
	AudioGlobal.play_hurt()
	currentHealth -= damageAmount
	print(currentHealth)
	if currentHealth <= 0:
		emit_signal("playerDied")
		print("player died.")
		AudioGlobal.play_death()
		queue_free()
	emit_signal("healthUpdated", currentHealth)
		
func get_closest_target() -> Node2D:
	var closest_target: Node2D = null
	var min_distance = AIM_ASSIST_RANGE
	var player_direction = Vector2.RIGHT.rotated(rotation).normalized() 
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance < min_distance:
				var to_enemy_vector = (enemy.global_position - global_position).normalized()
				var required_dot = cos(AIM_CONE_ANGLE)
				var actual_dot = player_direction.dot(to_enemy_vector)
				
				if actual_dot >= required_dot:
					min_distance = distance
					closest_target = enemy
					
	return closest_target

func fireProjectile():
	playerAnimator.play("fire")
	AudioGlobal.play_default_shoot_sound()
	var projectile = bullet.instantiate()
	projectile.setRotation(rotation)
	get_tree().root.add_child(projectile)
	
	projectile.set_bullet_stats(
		finalBulletSpeed, 
		finalDamage, 
		finalBulletLifetime, 
		finalBulletSize,
		finalBulletPierce
	)
	
	var muzzle = $Muzzle
	projectile.global_position = muzzle.global_position
	
	var directionVector = Vector2.RIGHT.rotated(rotation)
	projectile.setDirection(directionVector)
	
func _ready() -> void:
	update_stats()
	currentHealth = finalHealth
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("changeDir"):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_space_press_time < SWAP_TIMEOUT:
			_swap_tool()
			last_space_press_time = 0.0
			rDir = 0
			return
		last_space_press_time = current_time
		lastDir = rDir
		rDir = 0
		
	if event.is_action_released("changeDir"):
		rDir = lastDir * -1

func _swap_tool():
	if active_tool == Tool.BLASTER:
		active_tool = Tool.SHIELD
		$BlasterNode.visible = false
		$ShieldNode.visible = true
		$ShieldNode.monitoring = true
		fireTimer.stop()
	else:
		active_tool = Tool.BLASTER
		$ShieldNode.visible = false
		$BlasterNode.visible = true
		$ShieldNode.monitoring = false
		fireTimer.start()

func _on_fire_timer_timeout() -> void:
	fireProjectile()

func apply_health_upgrade():
	var old_max_health = finalHealth 
	update_stats() 
	
	var health_gain = finalHealth - old_max_health
	currentHealth += health_gain 
	currentHealth = min(currentHealth, finalHealth)
	emit_signal("healthUpdated", currentHealth)

func _process(delta: float) -> void:
	var targetSpeed = rDir * finalRotationSpeed
	var input_direction = Vector2.RIGHT.rotated(rotation)
	var target = get_closest_target()
	if is_instance_valid(target):
		var target_direction = (target.global_position - global_position).normalized()
		var required_rotation = target_direction.angle()
		var angle_delta = wrapf(required_rotation - rotation, -PI, PI)
		var assisted_speed = angle_delta * finalRotationSpeed * 1.5 
		targetSpeed = lerp(targetSpeed, assisted_speed, AIM_ASSIST_STRENGTH)
	currentRotationSpeed = lerp(currentRotationSpeed, targetSpeed, rotationAccel * delta)
	rotation += currentRotationSpeed * delta

	emit_signal("cooldownUpdated", fireTimer.time_left)
	emit_signal("healthUpdated", currentHealth)
	
