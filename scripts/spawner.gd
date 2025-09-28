extends Area2D

var enemyScene = preload("res://scenes/enemy.tscn")
var shooterEnemyScene = preload("res://scenes/shooter_enemy.tscn")
var SHOOTER_CHANCE = 0.15
@onready var spawnerArea = $SpawnerArea
@onready var spawnAreaX = spawnerArea.shape.size.x
@onready var spawnAreaY = spawnerArea.shape.size.y

func spawnEnemy():
	var randomAreaX = randf_range(0, spawnAreaX / 2.0)
	var randomAreaY = randf_range(0, spawnAreaY / 2.0)
	var spawn_position = global_position + Vector2(randomAreaX, randomAreaY)
	
	if Global.waveNumber >= 3:
		if randf() < SHOOTER_CHANCE:
			var newShooterEnemy = shooterEnemyScene.instantiate()
			newShooterEnemy.global_position = spawn_position
			get_parent().add_child(newShooterEnemy)
		else:
			var newBasicEnemy = enemyScene.instantiate()
			newBasicEnemy.global_position = spawn_position
			get_parent().add_child(newBasicEnemy)
	else:
		var newBasicEnemy = enemyScene.instantiate()
		newBasicEnemy.global_position = spawn_position
		get_parent().add_child(newBasicEnemy)
	

func _process(delta: float) -> void:
	pass
