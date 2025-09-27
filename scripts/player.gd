extends CharacterBody2D
var rSpeed = 2
var rDir = 1
var lastDir
var rDegrees
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

const baseFireRate = 1.0
const baseFireRateReduction = 0.05
const baseBulletSpeed = 500
const baseSpeedAddition = 50
const baseBulletDamage = 10
const baseHealth = 100
const baseHealthAddition = 50
const baseDamage = 10
const baseDamageAddition = 5
const basePierce = 1
const basePierceAddition = 1
const baseRotationSpeed = 2
const baseRotationSpeedAddition = 0.5
const baseBulletLifetime = 0.5
const baseBulletLifetimeAddition = 0.25
const baseBulletSize = 1
const baseBulletSizeAddition = 0.2

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
	fireTimer.wait_time = max(0.05, finalFireRate)
	emit_signal("fireRateChanged", fireTimer.wait_time)
	
	var speed_level = Global.upgrades["bullet_speed_level"] #2
	finalBulletSpeed = baseBulletSpeed + (speed_level * baseSpeedAddition)
	
	var health_level = Global.upgrades["health_level"] #3
	finalHealth = baseHealth + (health_level * baseHealthAddition)
	
	var damage_level = Global.upgrades["bullet_damage_level"] #4
	finalDamage = baseDamage + (damage_level * baseDamageAddition)
	
	var pierce_level = Global.upgrades["bullet_pierce_level"] #5
	finalBulletPierce = basePierce + (pierce_level * basePierceAddition)
	
	var rotation_level = Global.upgrades["rotation_speed_level"] #6
	finalRotationSpeed = baseRotationSpeed + (rotation_level * baseRotationSpeedAddition)
	
	var size_level = Global.upgrades["bullet_size_level"] #7
	finalBulletSize = baseBulletSize + (size_level * baseBulletSizeAddition)
	
	var lifetime_level = Global.upgrades["bullet_lifetime_level"] #8
	finalBulletLifetime = baseBulletLifetime + (lifetime_level * baseBulletLifetimeAddition)
	# 3. FIX: finalHealth
	# You should re-calculate and set the player's max finalHealth here too,
	# but for now, we only update the signal.
	emit_signal("healthUpdated", finalHealth)


func takeDamage(damageAmount):
	finalHealth -= damageAmount
	print(finalHealth)
	if finalHealth <= 0:
		emit_signal("playerDied")
		print("player died.")
		queue_free()
	
func fireProjectile():
	playerAnimator.play("fire")
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
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("changeDir"):
		lastDir = rDir
		rDir = 0
	if event.is_action_released("changeDir"):
		rDir = lastDir * -1
		
func _process(delta: float) -> void:
	rDegrees = finalRotationSpeed * rDir * delta
	rotation = rotation + rDegrees
	emit_signal("cooldownUpdated", fireTimer.time_left)
	emit_signal("healthUpdated", finalHealth)
	#print(fireTimer.time_left)
	
func _on_fire_timer_timeout() -> void:
	fireProjectile()
