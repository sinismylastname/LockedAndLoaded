extends Node2D
var spawners = []
@onready var waveTimer = $TimeInBetweenWaves
@onready var spawnerNode = $"../Spawner"
@onready var spawnTimer = $SpawnTimer
var intermissionTime = 30.0

signal intermission_started
signal intermission_time_updated(time_left) # NEW SIGNAL

func _ready():
	add_to_group("wave_manager")
	spawners = spawnerNode.get_children()
	Global.all_enemies_cleared.connect(_on_all_enemies_cleared)
	Global.game_started.connect(startWave) 

func _process(delta: float) -> void:
	if Global.is_intermission and waveTimer.is_stopped() == false:
		# Continuously emit the exact time remaining from the Timer node
		emit_signal("intermission_time_updated", waveTimer.time_left)

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
	if Global.is_intermission:
		return
	Global.is_intermission = true

	if intermissionTime > 0:
		waveTimer.start(intermissionTime)
		emit_signal("intermission_started")
	else:
		_on_intermission_ended()

func _on_time_in_between_waves_timeout() -> void:
	_on_intermission_ended()

func _on_intermission_ended():
	if not Global.is_intermission:
		return
	Global.is_intermission = false
	waveTimer.stop()
	
	Global.intermission_time = 0
	
	Global.enemiesSpawned = 0
	Global.next_wave()
	startWave()

func skip_intermission():
	if Global.is_intermission:
		waveTimer.stop()
		_on_intermission_ended()
