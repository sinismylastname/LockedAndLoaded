extends Node

signal upgrade_points_changed(new_points)
signal enemy_count_changed(newCount)
signal xp_changed(xp)
signal leveled_up(newLevel)
signal all_enemies_cleared
signal wave_started(waveNumber)
signal game_started
signal player_changed(new_player)
signal next_tp_point_changed(new_point)

var enemyCount = 0
var enemiesToSpawn = 10
var enemiesSpawned = 0
var enemyHP = 10
var enemySpeed = 50
var waveNumber = 1
var spawnTime = 1.0

var currentLevel = 1
var currentXP = 0
var XPNeeded = 100

var _player = null
var Player:
	get:
		return _player
	set(value):
		_player = value
		emit_signal("player_changed", _player)
var UpgradeUI = null
var CRTEffect = false

var upgrades = {
	"bullet_power_level": 0,
	"bullet_range_level": 0,
	"bullet_pierce_level": 0,
	"rotation_speed_level": 0,
	"fire_rate_level": 0,
	"health_level": 0,
}
var upgradePoints = 0

var intermission_time = 30
var is_intermission = false

var current_tp_points = 0
var max_tp_points = 2

var tp_point_array: Array = []
var current_tp_index = 0
var next_tp_index = 0
var next_tp_point = null:
	set(value):
		next_tp_point = value
		next_tp_point_changed.emit(value)
	get:
		return next_tp_point


func reset_game():
	upgrades["bullet_power_level"] = 0
	upgrades["bullet_range_level"] = 0
	upgrades["bullet_pierce_level"] = 0
	upgrades["rotation_speed_level"] = 0
	upgrades["fire_rate_level"] = 0
	upgrades["health_level"] = 0
	
	upgradePoints = 0
	currentLevel = 1
	currentXP = 0
	XPNeeded = 100
	
	waveNumber = 1
	enemiesToSpawn = 10
	enemiesSpawned = 0
	enemyCount = 0
	enemyHP = 10
	enemySpeed = 50
	spawnTime = 1.0
	
	ClassManager.connect("player_spawned", Callable(self, "_on_player_spawned"))
	connect("all_enemies_cleared", Callable(self, "_on_all_enemies_cleared"))
	var base_class_path = "res://scenes/player.tscn"
	ClassManager.spawn_player(base_class_path)
	get_tree().paused = false
	
	

func set_game_references(player_node, ui_node):
	Player = player_node
	UpgradeUI = ui_node
	
func addXP(amount: int):
	currentXP += amount
	
	if currentXP >= XPNeeded:
		level_up()

func level_up():
	currentLevel += 1
	currentXP -= XPNeeded 
	XPNeeded *= 1.2
	upgradePoints += 2 # i changed the amount of points to make the player feel like their points aren't like "pennies"
	#it makes the upgrades feel that much more "heftier"
	AudioGlobal.play_level_up()
	
	if is_instance_valid(Player):
		Player._level_up_vfx()
		
	leveled_up.emit(currentLevel)

func next_wave():
	waveNumber += 1
	enemiesSpawned = 0
	enemiesToSpawn += randi_range(1, 4) 
	spawnTime -= 0.075
	enemyHP += 2.5
	enemySpeed += 2.5
	
	wave_started.emit(waveNumber)

func increaseEnemyCount():
	enemyCount += 1
	enemy_count_changed.emit(enemyCount)

func decrease_enemy_count():
	enemyCount = max(enemyCount - 1, 0)
	enemy_count_changed.emit(enemyCount)
	
	if enemyCount <= 0 and enemiesSpawned >= enemiesToSpawn:
		all_enemies_cleared.emit()

func tp_point_possible():
	if current_tp_points < max_tp_points:
		current_tp_points += 1
		return true
	elif current_tp_points >= max_tp_points:
		return false

func apply_upgrade(stat_name: String):
	if upgradePoints > 0:
		upgrades[stat_name] += 1
		upgradePoints -= 1
		
		if stat_name == "health_level":
			Player.apply_health_upgrade() #because the old way made it so that upgrading your health filled the entire bar 
			
		upgrade_points_changed.emit(upgradePoints)
		if is_instance_valid(Player):
			Player.update_stats()
