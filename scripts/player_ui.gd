extends CanvasLayer
@onready var fireRateUI = $FireRateUI
@onready var healthBar = $HealthBarUI

func _ready():
	var Player = get_tree().get_root().find_child("Player", true, false)
	Player.connect("fireRateChanged", _on_player_fire_rate_changed)
	Player.connect("cooldownUpdated", _on_player_cooldown_updated)
	Player.connect("healthUpdated", _on_player_health_changed)
	Player.connect("playerDied", _on_player_died)

func _on_player_cooldown_updated(timeLeft):
	fireRateUI.value = timeLeft

func _on_player_fire_rate_changed(newFiringRate: Variant) -> void:
	fireRateUI.max_value = newFiringRate

func _on_player_health_changed(health):
	healthBar.value = health

func _on_player_died():
	healthBar.value = 0
	#add more death stuff here, like switching to a scene that says Game Over
