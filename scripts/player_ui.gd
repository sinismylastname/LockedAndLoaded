extends CanvasLayer
@onready var player_ui_root = $playerUIRoot
@onready var fireRateUI = $playerUIRoot/FireRateUI
@onready var healthBar = $playerUIRoot/HealthBarUI
@onready var enemyCounter = $playerUIRoot/EnemyCount
@onready var wave_notification = $playerUIRoot/WaveNotification
@onready var xp_bar = $playerUIRoot/XPBAR
@onready var intermission_label = $playerUIRoot/IntermissionLabel
@onready var skip_intermission = $playerUIRoot/SkipIntermission
var Player = null

func _ready():
	skip_intermission.visible = false
	call_deferred("connect_player_signals")
	Global.enemy_count_changed.connect(on_enemy_count_changed)
	enemyCounter.text = "Enemies: %d" % Global.enemyCount
	Global.wave_started.connect(_on_wave_started) 
	Global.connect("player_changed", Callable(self, "_on_player_changed"))
	Global.connect("xp_changed", Callable(self, "_on_player_xp_changed"))
	Global.connect("all_enemies_cleared", Callable(self, "_on_intermission_started"))
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

func _on_intermission_started():
	if !is_instance_valid(intermission_label):
		return

	intermission_label.visible = true
	skip_intermission.visible = true
	var countdown = Global.intermission_time

	while countdown > 0:
		intermission_label.text = "INTERMISSION: %d" % int(ceil(countdown))
		await get_tree().create_timer(0.1).timeout
		countdown -= 0.1

	intermission_label.visible = false


func _on_skip_intermission_pressed() -> void:
	if not Global.is_intermission:
		return
	intermission_label.visible = false
	skip_intermission.visible = false
	Global.is_intermission = false

	var wave_manager = get_tree().current_scene.get_node_or_null("WaveManager")
	if wave_manager:
		wave_manager._on_intermission_ended()


func _process(delta):
	if is_instance_valid(Global.Player):
		player_ui_root.position = Global.Player.global_position
