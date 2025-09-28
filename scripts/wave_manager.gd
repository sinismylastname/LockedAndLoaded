extends Node2D
var spawners = []
@onready var waveTimer = $TimeInBetweenWaves
@onready var spawnerNode = $"../Spawner"
@onready var spawnTimer = $SpawnTimer
var waveTime = 2.0


func _ready():
	spawners = spawnerNode.get_children()
	Global.all_enemies_cleared.connect(_on_all_enemies_cleared)
	startWave()

func startWave():
	spawnTimer.start(Global.spawnTime)
	Global.wave_started.emit()

func _on_spawn_timer_timeout() -> void:
	if Global.enemiesSpawned < Global.enemiesToSpawn:
		var player_node = get_tree().get_root().find_child("Player", true, false)
		
		if Global.enemiesSpawned < Global.enemiesToSpawn:
			var randomSpawner = spawners[randi_range(0, spawners.size()-1)]
			randomSpawner.spawnEnemy()
			Global.enemiesSpawned += 1
		else:
			spawnTimer.stop()

func _on_all_enemies_cleared():
	waveTimer.start(waveTime)

func _on_time_in_between_waves_timeout() -> void:
	Global.next_wave()
	waveTimer.stop()
	startWave()
