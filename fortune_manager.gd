extends CanvasLayer 
signal fortune_given(effect_name) 

@export var popup_scene: PackedScene = preload("res://bushman_ui.tscn")
var current_popup = null
var rounds_since_fortune = 0
var fortune_interval = 3
var Player = null 

func set_game_references(player_node):
	Player = player_node
	
func show_bushman_popup():
	get_tree().paused = true 
	var popup_instance = popup_scene.instantiate()
	current_popup = popup_instance
	popup_instance.connect("fortune_given", Callable(self, "_on_fortune_given"))
	
	add_child(popup_instance)


func _on_fortune_given(effect_name: String):
	if effect_name == "HEAL_SMALL":
		if is_instance_valid(Player):
			Player.currentHealth += 10
		else:
			print("ERROR: Player reference lost for healing.")

	elif effect_name == "DAMAGE_BOOST":
		Global.upgrades["bullet_power_level"] += 3

	elif effect_name == "RANGE_BUFF":
		Global.upgrades["bullet_range_level"] += 3

	elif effect_name == "FIRERATE_BUFF":
		Global.upgrades["fire_rate_level"] += 3
	
	if is_instance_valid(Player):
		Player.update_stats()
		
	current_popup.queue_free()
	current_popup = null
	get_tree().paused = false 
