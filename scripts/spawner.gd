extends Area2D

var enemyScene = preload("res://scenes/enemy.tscn")
var shooterEnemyScene = preload("res://scenes/shooter_enemy.tscn")

var speedy_scene = preload("res://scenes/fast_enemy.tscn")
var SHOOTER_CHANCE = 0.15
var SPEEDY_CHANCE = 0.4

var SHOOTER_CHANCE = 0.15

@onready var spawnerArea = $SpawnerArea
@onready var spawnAreaX = spawnerArea.shape.size.x
@onready var spawnAreaY = spawnerArea.shape.size.y

func spawnEnemy():
	var randomAreaX = randf_range(0, spawnAreaX / 2.0)
	var randomAreaY = randf_range(0, spawnAreaY / 2.0)
	var spawn_position = global_position + Vector2(randomAreaX, randomAreaY)
	
	if randf() < SPEEDY_CHANCE:
		var newSpeedyEnemy = speedy_scene.instantiate()
		newSpeedyEnemy.global_position = spawn_position
		get_parent().add_child(newSpeedyEnemy)
		return
	

	if Global.waveNumber >= 3:
		if randf() < SHOOTER_CHANCE:
			var newShooterEnemy = shooterEnemyScene.instantiate()
			newShooterEnemy.global_position = spawn_position
			get_parent().add_child(newShooterEnemy)

			return


		else:
			var newBasicEnemy = enemyScene.instantiate()
			newBasicEnemy.global_position = spawn_position
			get_parent().add_child(newBasicEnemy)

			return


	else:
		var newBasicEnemy = enemyScene.instantiate()
		newBasicEnemy.global_position = spawn_position
		get_parent().add_child(newBasicEnemy)

		return


	

func _process(delta: float) -> void:
	pass
