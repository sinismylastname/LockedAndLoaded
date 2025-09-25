extends CharacterBody2D
var rSpeed = 2
var rDir = 1
var lastDir
var rDegrees
var health = 100
var iFrameSeconds = 0.5
  
var bullet = preload("res://scenes/bullet.tscn")

signal fireRateChanged(newFiringRate)
signal cooldownUpdated
signal healthUpdated
signal playerDied

@onready var fireTimer = $FireTimer
@onready var invincTimer = $InvincibilityTimer

func changeFireRate(newTime):
	fireTimer.wait_time = newTime
	emit_signal("fireRateChanged", fireTimer.time_left)

func takeDamage(damageAmount):
	health -= damageAmount
	print(health)
	if health <= 0:
		emit_signal("playerDied")
		print("player died.")
		queue_free()
	
func fireProjectile():
	var projectile = bullet.instantiate()
	projectile.setRotation(rotation)
	get_tree().root.add_child(projectile)
	
	var muzzle = $Muzzle
	projectile.global_position = muzzle.global_position
	
	var directionVector = Vector2.RIGHT.rotated(rotation)
	projectile.setDirection(directionVector)
	
func _ready() -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("changeDir"):
		lastDir = rDir
		rDir = 0
	if event.is_action_released("changeDir"):
		rDir = lastDir * -1
		
func _process(delta: float) -> void:
	rDegrees = rSpeed * rDir * delta
	rotation = rotation + rDegrees
	emit_signal("cooldownUpdated", fireTimer.time_left)
	emit_signal("healthUpdated", health)
	#print(fireTimer.time_left)
	
func _on_fire_timer_timeout() -> void:
	fireProjectile()
