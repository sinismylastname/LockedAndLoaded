extends CanvasLayer
@onready var points_label = $UpgradePoints

func _ready():
	Global.upgrade_points_changed.connect(_on_upgrade_points_changed)
	Global.upgrade_menu_open.connect(_on_upgrade_menu_open)
	
func _on_upgrade_points_changed(new_points: int):
	points_label.text = "Points: %d" % new_points
	
func _on_add_bullet_speed_pressed() -> void:
	Global.apply_upgrade("bullet_speed_level")

func _on_add_bullet_damage_pressed() -> void:
	Global.apply_upgrade("bullet_damage_level")

func _on_add_bullet_lifetime_pressed() -> void:
	Global.apply_upgrade("bullet_lifetime_level")

func _on_add_bullet_size_pressed() -> void:
	Global.apply_upgrade("bullet_size_level")

func _on_add_bullet_pierce_pressed() -> void:
	Global.apply_upgrade("bullet_pierce_level")

func _on_add_health_pressed() -> void:
	Global.apply_upgrade("health_level")

func _on_add_rotation_speed_pressed() -> void:
	Global.apply_upgrade("rotation_speed_level")

func _on_add_firerate_pressed() -> void:
	Global.apply_upgrade("fire_rate_level")
	
func _on_continue_pressed() -> void:
	visible = false
	Engine.time_scale = 1

func _on_upgrade_menu_open() -> void:
	_on_upgrade_points_changed(Global.upgradePoints)
	visible = true
	
