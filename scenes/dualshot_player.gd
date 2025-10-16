extends "res://scripts/player.gd"

var fire_toggle = true

func _ready():
	super._ready()

func apply_class_modifiers():
	super.apply_class_modifiers()
	finalFireRate *= 0.5
	finalDamage *= 1


func fireProjectile():
	playerAnimator.play("fire")
	AudioGlobal.play_default_shoot_sound()
	
	var muzzle = $FrontMuzzle if fire_toggle else $BackMuzzle
	var projectile_instance = projectile.instantiate()
	get_tree().root.add_child(projectile_instance)
	
	projectile_instance.global_position = muzzle.global_position
	projectile_instance.setRotation(muzzle.global_rotation)
	projectile_instance.set_bullet_stats(
		finalBulletSpeed, 
		finalDamage, 
		finalBulletLifetime, 
		finalBulletSize,
		finalBulletPierce
	)
	
	var directionVector = Vector2.RIGHT.rotated(muzzle.global_rotation)
	projectile_instance.setDirection(directionVector)
	
	fire_toggle = not fire_toggle
