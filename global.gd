extends Node

signal upgrade_points_changed(new_points)
signal upgrade_menu_open

var enemyCount = 0

var currentLevel = 1
var currentXP = 0
var XPNeeded = 100

var Player = null
var UpgradeUI = null

var upgrades = {
	"bullet_speed_level": 1,
	"bullet_damage_level": 1,
	"bullet_pierce_level": 1,
	"bullet_size_level": 1,
	"rotation_speed_level": 1,
	"fire_rate_level": 1,
	"health_level": 1,
	"bullet_lifetime_level": 1
}

var upgradePoints = 0

signal enemy_count_changed(newCount)
signal leveled_up(newLevel)
signal all_enemies_cleared

func set_game_references(player_node, ui_node):
	Player = player_node
	UpgradeUI = ui_node
	
func addXP(amount: int):
	currentXP += amount
	
	if currentXP >= XPNeeded:
		level_up()

func level_up():
	currentLevel += 1
	currentLevel -= XPNeeded 
	XPNeeded *= 1.5
	upgrade_menu_open.emit()
	Engine.time_scale = 0.01
	upgradePoints += 3
	leveled_up.emit(currentLevel)

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
		upgrade_points_changed.emit(upgradePoints)
		if is_instance_valid(Player):
			Player.update_stats()
