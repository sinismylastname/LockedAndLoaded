extends Area2D

var enemyScene = preload("res://scenes/enemy.tscn")
@onready var spawnerArea = $SpawnerArea
@onready var spawnAreaX = spawnerArea.shape.size.x
@onready var spawnAreaY = spawnerArea.shape.size.y

func spawnEnemy():
	var randomAreaX = randf_range(0, spawnAreaX/2)
	var randomAreaY = randf_range(0, spawnAreaY/2)
	
	var newEnemy = enemyScene.instantiate()
	newEnemy.global_position = global_position + Vector2(randomAreaX, randomAreaY)
	get_parent().add_child(newEnemy)

func _process(delta: float) -> void:
	pass
