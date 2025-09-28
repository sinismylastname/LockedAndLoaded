extends Area2D

var playerDirection = Vector2.ZERO
var speed = Global.enemySpeed
var health = Global.enemyHP
var knockback_vector = Vector2.ZERO
var knockback_timer = 0.0
const KNOCKBACK_DURATION = 0.15
@onready var player = get_tree().get_root().find_child("Player", true, false)

func apply_knockback(direction_vector: Vector2, force: float):
	knockback_vector = direction_vector * force
	knockback_timer = KNOCKBACK_DURATION 

func _ready():
	Global.increaseEnemyCount()

func enemyDied():
	AudioGlobal.play_death()
	Global.decrease_enemy_count()
	Global.addXP(25)
	queue_free()

func takeDamage(damageAmount):
	AudioGlobal.play_hurt()
	health -= damageAmount
	print(health )
	if health <= 0:
		enemyDied()
		
func _process(delta: float) -> void:
	if knockback_timer > 0:
		global_position += knockback_vector * delta
		knockback_vector = lerp(knockback_vector, Vector2.ZERO, 15.0 * delta)
		knockback_timer -= delta
		if knockback_timer <= 0:
			knockback_vector = Vector2.ZERO 
	elif knockback_timer <= 0:
		if is_instance_valid(player):
			playerDirection = (player.global_position - global_position).normalized()
			global_position += playerDirection * speed * delta
			look_at(player.global_position)
	else:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.takeDamage(25)
		Global.decrease_enemy_count()
		queue_free()
