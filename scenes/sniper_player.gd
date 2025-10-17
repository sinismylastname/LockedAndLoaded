extends "res://scripts/player.gd"
#plans for sniper class:
#add instant firing projectiles. basically they are straight up BEAMS of power
#also add faster spinning and stronger aim assist power?
#i mean i want it to freakin snipe, but should i give it infinite pierce? seems like it'd be freakin op
func _ready() -> void:
	super._ready()
	projectile = preload("res://scenes/projectiles/beam.tscn")

func apply_class_modifiers():
	super.apply_class_modifiers()
	finalFireRate *= 2
	finalDamage *= 1.25
	finalBulletPierce += 999999
	finalHealth *= 0.5

func fireProjectile():
	playerAnimator.play("fire")
	AudioGlobal.play_default_shoot_sound()
	var projectile = projectile.instantiate()
	projectile.global_position = $FrontMuzzle.global_position
	projectile.setRotation(rotation)
	get_tree().root.add_child(projectile)
	
	projectile.set_bullet_stats(
		finalDamage, 
		finalBulletLifetime, 
		finalBulletPierce
	)
