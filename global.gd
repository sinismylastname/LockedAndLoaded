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
signal offer_upgrades(choices)

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
		
var score = 0

var upgrade_pool = [
	{
		"name": "Bigger Bullets",
		"desc": "Bullets are 25% larger.",
		"stat": "bullet_size",
		"display": "+25%",
		"effect": "increase_bullet_size"
	},
	{
		"name": "Faster Reload",
		"desc": "Your gun reloads 30% faster.",
		"stat": "reload_speed",
		"display": "+30%",
		"effect": "increase_reload_speed"
	},
	{
		"name": "Homing Rounds",
		"desc": "Bullets slightly track enemies.",
		"stat": "tracking",
		"display": "Homing",
		"effect": "enable_homing"
	}
]

func reset_game():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()

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
	score = 0
	
	waveNumber = 1
	enemiesToSpawn = 10
	enemiesSpawned = 0
	enemyCount = 0
	enemyHP = 10
	enemySpeed = 50
	spawnTime = 1.0
	
	
	enemy_count_changed.emit(enemyCount)
	ClassManager.connect("player_spawned", Callable(self, "_on_player_spawned"))
	connect("all_enemies_cleared", Callable(self, "_on_all_enemies_cleared"))
	var base_class_path = "res://scenes/player.tscn"
	if Player:
		Player.queue_free()
	ClassManager.spawn_player(base_class_path)
	get_tree().paused = false
	
	game_started.emit()

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
	upgradePoints += 2
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

func _rand_choice(array):
	return array[randi() % array.size()]

func _stat_option(stat_key: String, delta: float) -> Dictionary:
	return {
		"type": "stat",
		"stat": stat_key,
		"delta": delta,
		"display": "%+s %s" % [delta, stat_key.replace("_", " ")],
	}

func _gimmick_option(id: String, name: String, desc: String, icon: Texture) -> Dictionary:
	return {
		"type": "gimmick",
		"id": id,
		"name": name,
		"desc": desc,
		"icon": icon,
	}

func get_upgrade_choices() -> Array:
	var stat_pool = [
		_stat_option("bullet_power_level", 1),
		_stat_option("bullet_range_level", 1),
		_stat_option("bullet_pierce_level", 1),
		_stat_option("rotation_speed_level", 1),
		_stat_option("fire_rate_level", 1),
		_stat_option("health_level", 1)
	]
	var gimmick_pool = [
		_gimmick_option("instant_projectile", "Instant Projectile", "Projectile starts fast (short burst).", null),
		_gimmick_option("homing_projectile", "Homing Rounds", "Bullets slightly home to nearest enemy.", null),
		_gimmick_option("split_on_death", "Shrapnel", "Bullets split into 3 smaller on hit.", null),
		_gimmick_option("pierce_plus", "Piercing Rounds", "Give +1 projectile pierce.", null)
	]
	var choices = []
	var attempts = 0
	while choices.size() < 3 and attempts < 20:
		attempts += 1
		if randi() % 2 == 0:
			var s = _rand_choice(stat_pool).duplicate(true)
			if not choices.has(s):
				choices.append(s)
		else:
			var g = _rand_choice(gimmick_pool).duplicate(true)
			if not choices.has(g):
				choices.append(g)
	return choices

func offer_upgrades_to_player():
	var choices = get_upgrade_choices()
	print("Emitting offer_upgrades with choices:", choices)
	emit_signal("offer_upgrades", choices)

func apply_upgrade_choice(choice: Dictionary):
	if choice["type"] == "stat":
		var stat = choice["stat"]
		var delta = int(choice["delta"])
		upgrades[stat] = upgrades.get(stat, 0) + delta
		upgrade_points_changed.emit(upgradePoints)
		if is_instance_valid(Player):
			Player.update_stats()
	elif choice["type"] == "gimmick":
		var id = choice["id"]
		if is_instance_valid(Player):
			Player.apply_gimmick(id)

func apply_upgrade(stat_name: String):
	if upgradePoints > 0:
		upgrades[stat_name] += 1
		upgradePoints -= 1
		
		if stat_name == "health_level":
			Player.apply_health_upgrade()
			
		upgrade_points_changed.emit(upgradePoints)
		if is_instance_valid(Player):
			Player.update_stats()
