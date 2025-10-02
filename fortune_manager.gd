extends CanvasLayer 

@export var popup_scene: PackedScene = preload("res://bushman_ui.tscn")
var current_popup = null
var rounds_since_fortune = 0
var fortune_interval = 9999999999999999999
var Player = null 

func _ready():
	pass

func set_game_references(player_node):
	Player = player_node
	
func _bushmanShowsUp(waveNumber: int):
	print("Bushman check: Global.waveNumber is ", Global.waveNumber)
	if Global.waveNumber % fortune_interval == 0:
		print("Bushman check PASSED!")
		show_bushman_popup()
	else:
		print("Bushman check FAILED.")

func show_bushman_popup():
	get_tree().paused = true 
	var popup_instance = popup_scene.instantiate()
	current_popup = popup_instance
	var child = current_popup.find_child("Cards", true, false) 
	if is_instance_valid(child):
		print("fortune will be connected to le manager")
		child.connect("fortune_given", Callable(self, "_on_fortune_given"))
	else:
		print("CRITICAL ERROR: Failed to find the Cards node to connect the signal!")
		return
	add_child(current_popup)

func _on_fortune_given(effect_name: String):
	if !is_instance_valid(Player):
		print("CRITICAL ERROR: Player reference is NULL. Cannot apply fortune, but will clean up.")

	else: 
		if effect_name == "HEAL_SMALL":
			Player.currentHealth += 10
			print("hp given")

		elif effect_name == "DAMAGE_BOOST":
			Global.upgrades["bullet_power_level"] += 3
			print("damage level boosted")
			
		elif effect_name == "RANGE_BUFF":
			Global.upgrades["bullet_range_level"] += 3
			print("range level boosted")
			
		elif effect_name == "FIRERATE_BUFF":
			Global.upgrades["fire_rate_level"] += 3
			print("firerate level boosted")
			
		Player.update_stats()
		
	print("Cleanup initiated.") 
	current_popup.queue_free()
	current_popup = null
	get_tree().paused = false
