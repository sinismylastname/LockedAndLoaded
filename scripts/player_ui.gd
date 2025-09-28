extends CanvasLayer
@onready var fireRateUI = $FireRateUI
@onready var healthBar = $HealthBarUI
@onready var enemyCounter = $EnemyCount
@onready var wave_notification = $WaveNotification
@onready var Player = get_tree().get_root().find_child("Player", true, false)

func _ready():
	call_deferred("connect_player_signals")
	
	Global.enemy_count_changed.connect(on_enemy_count_changed)
	enemyCounter.text = "Enemies: %d" % Global.enemyCount
	Global.wave_started.connect(_on_wave_started) 

func connect_player_signals():
	Player = get_tree().get_root().find_child("Player", true, false)
	if is_instance_valid(Player):
		Player.connect("fireRateChanged", _on_player_fire_rate_changed)
		Player.connect("cooldownUpdated", _on_player_cooldown_updated)
		Player.connect("healthUpdated", _on_player_health_changed)
		Player.connect("playerDied", _on_player_died)
	else:
		print("Error: Player node not found for UI connection.")
		
func _on_player_cooldown_updated(timeLeft):
	fireRateUI.set_max(Player.finalFireRate)
	fireRateUI.value = timeLeft

func _on_player_fire_rate_changed(newFiringRate):
	#fireRateUI.max_value = newFiringRate
	pass

func _on_player_health_changed(health):
	healthBar.max_value = Global.Player.finalHealth
	healthBar.value = health

func _on_player_died():
	healthBar.value = 0
		
func on_enemy_count_changed(newCount):
	enemyCounter.text = "Enemies: %d" % newCount

func _on_wave_started(new_wave_number):
	wave_notification.text = "WAVE %d" % new_wave_number
	var existing_tween = wave_notification.get_node_or_null("WaveTween")
	if existing_tween:
		existing_tween.kill()

	var tween = create_tween()
	tween.tween_property(wave_notification, "modulate", Color(1, 1, 1, 1), 0.5) 
	tween.tween_interval(1.5) 
	tween.tween_property(wave_notification, "modulate", Color(1, 1, 1, 0), 1.0)
