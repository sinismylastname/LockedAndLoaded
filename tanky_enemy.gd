extends "res://scripts/enemy.gd"

func _ready():
	super._ready()
	body_color_1 = Color(0.529, 0.027, 1.0, 1.0)
	body_color_2 = Color(0.451, 0.153, 0.451)
	health = Global.enemyHP * 2
	speed = Global.enemySpeed / 2
	particle_color = Color(0.529, 0.027, 1.0, 1.0)

func apply_knockback(direction_vector: Vector2, force: float):
	knockback_vector = direction_vector * force / 3
	knockback_timer = KNOCKBACK_DURATION 

func enemyDied():
	UI_Global.add_shake(0.3)
	AudioGlobal.play_death()
	Global.decrease_enemy_count()
	Global.addXP(45)
	Global.emit_signal("xp_changed", 45)
	
	_xp_popup(45)
	
	var particles = death_particles_scene.instantiate()
	particles.global_position = global_position
	particles.modulate = particle_color
	get_tree().current_scene.add_child(particles)
	particles.emitting = true
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.takeDamage(30)
		Global.decrease_enemy_count()
		queue_free()
