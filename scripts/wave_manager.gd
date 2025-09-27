extends Node2D
var spawners = []
@onready var waveTimer = $TimeInBetweenWaves
@onready var spawnerNode = $"../Spawner"
var waveTime = 2.0

@onready var spawnTimer = $SpawnTimer
var spawnTime = 1.0

var enemyCount
var enemiesToSpawn = 10
var enemiesSpawned = 0
var waveNumber = 1

func _ready():
	spawners = spawnerNode.get_children()
	startWave()

func countEnemies():
	enemyCount = Global.enemyCount
	#print(enemyCount)

func startWave():
	spawnTimer.start(spawnTime)

func _on_spawn_timer_timeout() -> void:
	if enemiesSpawned < enemiesToSpawn:
		var player_node = get_tree().get_root().find_child("Player", true, false)
		
		if enemiesSpawned < enemiesToSpawn:
			var randomSpawner = spawners[randi_range(0, spawners.size()-1)]
			randomSpawner.spawnEnemy()
			enemiesSpawned += 1
		else:
			spawnTimer.stop()

func _on_time_in_between_waves_timeout() -> void:
	waveNumber += 1
	enemiesSpawned = 0
	enemiesToSpawn += 5
	waveTimer.stop()
	startWave()

func _process(delta: float) -> void:
	countEnemies()
	if spawnTimer.is_stopped() and enemiesToSpawn == enemiesSpawned and get_tree().get_nodes_in_group("enemies").size() == 0:
		waveTimer.start(waveTime)
