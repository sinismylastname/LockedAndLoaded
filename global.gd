extends Node

signal upgrade_points_changed(new_points)
signal upgrade_menu_open
signal enemy_count_changed(newCount)
signal leveled_up(newLevel)
signal all_enemies_cleared
signal wave_started(waveNumber)
signal game_started

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

var Player = null
var UpgradeUI = null

var upgrades = {
	"bullet_speed_level": 0,
	"bullet_damage_level": 0,
	"bullet_pierce_level": 0,
	"bullet_size_level": 0,
	"rotation_speed_level": 0,
	"fire_rate_level": 0,
	"health_level": 0,
	"bullet_lifetime_level": 0
}

var upgradePoints = 0

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
	XPNeeded *= 1.15
	Engine.time_scale = 0.005
	upgradePoints += 3
	upgrade_menu_open.emit()
	leveled_up.emit(currentLevel)

func next_wave():
	waveNumber += 1
	enemiesSpawned = 0
	enemiesToSpawn += 2 
	spawnTime -= 0.05
	enemyHP += 5
	enemySpeed += 5
	
	wave_started.emit(waveNumber)

func increaseEnemyCount():
	enemyCount += 1
	enemy_count_changed.emit(enemyCount)

func decrease_enemy_count():
	enemyCount -= 1
	enemy_count_changed.emit(enemyCount)
	
	if enemyCount == 0 and enemiesSpawned == enemiesToSpawn:
		all_enemies_cleared.emit()
	
func apply_upgrade(stat_name: String):
	if upgradePoints > 0:
		upgrades[stat_name] += 1
		upgradePoints -= 1
		
		if stat_name == "health_level":
			Player.apply_health_upgrade() #because the old way made it so that upgrading your health filled the entire bar 
			
		upgrade_points_changed.emit(upgradePoints)
		if is_instance_valid(Player):
			Player.update_stats()
