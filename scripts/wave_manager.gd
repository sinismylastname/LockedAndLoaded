extends Node2D
var spawners = []
@onready var waveTimer = $TimeInBetweenWaves
@onready var spawnerNode = $"../Spawner"
@onready var spawnTimer = $SpawnTimer
var intermissionTime = 30.0

signal intermission_started
func _ready():
	spawners = spawnerNode.get_children()
	Global.all_enemies_cleared.connect(_on_all_enemies_cleared)
	startWave()

func startWave():
	Global.is_intermission = false
	spawnTimer.start(Global.spawnTime)

func _on_spawn_timer_timeout() -> void:
	if Global.is_intermission:
		spawnTimer.stop()
		return

	if Global.enemiesSpawned < Global.enemiesToSpawn:
		var randomSpawner = spawners[randi_range(0, spawners.size()-1)]
		randomSpawner.spawnEnemy()
		Global.enemiesSpawned += 1
	else:
		spawnTimer.stop()

func _on_all_enemies_cleared():
	Global.is_intermission = true
	if intermissionTime > 0:
		Global.intermission_time = intermissionTime
		waveTimer.start(intermissionTime)
		emit_signal("intermission_started")
	else:
		_on_intermission_ended()

func _on_time_in_between_waves_timeout() -> void:
	_on_intermission_ended()

func _on_intermission_ended():
	Global.is_intermission = false
	Global.next_wave()
	waveTimer.stop()
	Global.enemiesSpawned = 0
	startWave()
