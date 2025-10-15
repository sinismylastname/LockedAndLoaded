extends "res://scripts/enemy.gd"

func _ready():
	super._ready()
	speed = Global.enemySpeed * 2

func enemyDied():
	UI_Global.add_shake(0.2)
	AudioGlobal.play_death()
	Global.decrease_enemy_count()
	Global.addXP(10)
	Global.emit_signal("xp_changed", 10)
	
	var particles = death_particles_scene.instantiate()
	particles.global_position = global_position
	particles.color = Color(0.966, 0.952, 0.0, 1.0)
	get_tree().current_scene.add_child(particles)
	particles.emitting = true
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.takeDamage(10)
		Global.decrease_enemy_count()
		queue_free()
