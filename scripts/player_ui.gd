extends CanvasLayer
@onready var fireRateUI = $FireRateUI
@onready var healthBar = $HealthBarUI
@onready var enemyCounter = $EnemyCount
@onready var wave_notification = $WaveNotification
@onready var xp_bar = $XPBAR
var Player = null

func _ready():
	call_deferred("connect_player_signals")
	Global.enemy_count_changed.connect(on_enemy_count_changed)
	enemyCounter.text = "Enemies: %d" % Global.enemyCount
	Global.wave_started.connect(_on_wave_started) 
	Global.connect("player_changed", Callable(self, "_on_player_changed"))
	Global.connect("xp_changed", Callable(self, "_on_player_xp_changed"))
	_on_player_changed(Global.Player)

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
	if !is_instance_valid(Global.Player):
		return
	if Global.Player.finalHealth == null:
		return
	healthBar.max_value = Global.Player.finalHealth
	healthBar.value = health

func _on_player_xp_changed(xp):
	var new_value = Global.currentXP
	var tween = create_tween()
	tween.tween_property(xp_bar, "value", new_value, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	

func _on_player_changed(new_player):
	Player = new_player

	if is_instance_valid(Player):
		Player.connect("fireRateChanged", Callable(self, "_on_player_fire_rate_changed"))
		Player.connect("cooldownUpdated", Callable(self, "_on_player_cooldown_updated"))
		Player.connect("healthUpdated", Callable(self, "_on_player_health_changed"))
		Player.connect("playerDied", Callable(self, "_on_player_died"))

		_on_player_health_changed(Player.currentHealth) # immediately update UI
	else:
		print("UI: New player instance invalid")

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
