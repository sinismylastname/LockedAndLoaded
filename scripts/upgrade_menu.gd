extends Control
@onready var points_label = $UpgradePoints

func _ready():
	Global.upgrade_points_changed.connect(_on_upgrade_points_changed)
	Global.leveled_up.connect(_on_level_up_changed)
	
func _on_upgrade_points_changed(new_points: int):
	points_label.text = "Upgrade Points: %d" % new_points

func _on_add_bullet_damage_pressed() -> void: #power
	Global.apply_upgrade("bullet_power_level")

func _on_add_bullet_lifetime_pressed() -> void: #range
	Global.apply_upgrade("bullet_range_level")

func _on_add_bullet_pierce_pressed() -> void:
	Global.apply_upgrade("bullet_pierce_level")

func _on_add_health_pressed() -> void:
	Global.apply_upgrade("health_level")

func _on_add_rotation_speed_pressed() -> void:
	Global.apply_upgrade("rotation_speed_level")

func _on_add_firerate_pressed() -> void:
	Global.apply_upgrade("fire_rate_level")

func _on_level_up_changed(level):
	$Levels.text = str("Level: ", Global.currentLevel)

func _process(delta: float) -> void:
	$Power/PowerLevelDisplay.text = str(Global.upgrades["bullet_power_level"])
	$Range/RangeLevelDisplay.text = str(Global.upgrades["bullet_range_level"])
	$Pierce/PierceLevelDisplay.text = str(Global.upgrades["bullet_pierce_level"])
	$Health/HealthLevelDisplay.text = str(Global.upgrades["health_level"])
	$RotationSpeed/RotationLevelDisplay.text = str(Global.upgrades["rotation_speed_level"])
	$Firerate/FirerateLevelDisplay.text = str(Global.upgrades["fire_rate_level"])
	#all of this to display the current level of your thingamabob.
