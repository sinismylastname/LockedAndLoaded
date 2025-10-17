extends Area2D

var enemyScene = preload("res://scenes/enemy.tscn")
var shooterEnemyScene = preload("res://scenes/shooter_enemy.tscn")
var speedy_scene = preload("res://scenes/fast_enemy.tscn")
var tanky_scene = preload("res://scenes/tanky_enemy.tscn")
var lucky_block_scene = preload("res://scenes/lucky_block_enemy.tscn")
var SHOOTER_CHANCE = 0.2
var SPEEDY_CHANCE = 0.2
var TANKY_CHANCE = 0.2
var LUCKY_BLOCK_CHANCE = 0.2


@onready var spawnerArea = $SpawnerArea
@onready var spawnAreaX = spawnerArea.shape.size.x
@onready var spawnAreaY = spawnerArea.shape.size.y

func spawnEnemy():
	if Global.is_intermission:
		return
	
	var randomAreaX = randf_range(0, spawnAreaX / 2.0)
	var randomAreaY = randf_range(0, spawnAreaY / 2.0)
	var spawn_position = global_position + Vector2(randomAreaX, randomAreaY)

	var roll = randf()

	if roll < SPEEDY_CHANCE:
		_spawn(speedy_scene, spawn_position)
	elif roll < SPEEDY_CHANCE + TANKY_CHANCE:
		_spawn(tanky_scene, spawn_position)
	elif roll < SPEEDY_CHANCE + TANKY_CHANCE + LUCKY_BLOCK_CHANCE:
		_spawn(lucky_block_scene, spawn_position)
	elif Global.waveNumber >= 3 and roll < SPEEDY_CHANCE + TANKY_CHANCE + LUCKY_BLOCK_CHANCE + SHOOTER_CHANCE:
		_spawn(shooterEnemyScene, spawn_position)
	else:
		_spawn(enemyScene, spawn_position)

func _spawn(scene, pos):
	var e = scene.instantiate()
	e.global_position = pos
	get_parent().add_child(e)

func _process(delta: float) -> void:
	pass
