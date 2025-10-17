extends Node

signal upgrade_points_changed(new_points)
signal upgrade_menu_open
signal enemy_count_changed(newCount)
signal xp_changed(xp)
signal leveled_up(newLevel)
signal all_enemies_cleared
signal wave_started(waveNumber)
signal game_started
signal player_changed(new_player)
signal upgrade_continue(boolean)

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
	get_tree().paused = true
	upgradePoints += 5
	upgrade_menu_open.emit()
	leveled_up.emit(currentLevel)
	upgrade_continue.emit(false)

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
		is_intermission = true
	
func _on_all_enemies_cleared():
	is_intermission = true
	await get_tree().create_timer(intermission_time).timeout
	is_intermission = false
	next_wave()
	

func apply_upgrade(stat_name: String):
	if upgradePoints > 0:
		upgrades[stat_name] += 1
		upgradePoints -= 1
		
		if stat_name == "health_level":
			Player.apply_health_upgrade() #because the old way made it so that upgrading your health filled the entire bar 
			
		upgrade_points_changed.emit(upgradePoints)
		if is_instance_valid(Player):
			Player.update_stats()
