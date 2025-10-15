extends Area2D

var KNOCKBACK_FORCE = 4000 
const PROJECTILE_GROUP = "enemy_projectiles"
const ENEMY_GROUP = "enemies"

func _ready():
	monitoring = false

func _on_area_entered(area: Area2D):
	if area.is_in_group(ENEMY_GROUP):
		var player_center = get_parent().global_position
		var knockback_direction = (area.global_position - player_center).normalized()
		print("enemy touched")
		if area.has_method("apply_knockback"):
			area.apply_knockback(knockback_direction, KNOCKBACK_FORCE)
		if area.has_method("takeDamage"):
			area.takeDamage(5)
	
	if area.is_in_group(PROJECTILE_GROUP):
		area.queue_free()
