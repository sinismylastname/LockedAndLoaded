extends Node

var current_player : Node
var player_class_scene : PackedScene
signal player_spawned(player)

func spawn_player(path):
	player_class_scene = load(path)
	current_player = player_class_scene.instantiate()
	
	var spawn_point = get_node_or_null("SpawnPoint")
	if spawn_point:
		current_player.global_position = spawn_point.global_position
	else:
		current_player.global_position = Vector2(576.0, 323.0)
		
	get_parent().add_child(current_player)   
	await get_tree().process_frame
	Global.Player = current_player
	emit_signal("player_spawned", current_player)

func switch_class(new_class_scene_path: String):
	if current_player:
		var state = current_player.get_state() 
		var parent = current_player.get_parent()
		current_player.queue_free()
		player_class_scene = load(new_class_scene_path)
		current_player = player_class_scene.instantiate()
		parent.add_child(current_player)
		current_player.global_position = state["position"]
		current_player.apply_state(state) 
		current_player.update_stats()
		current_player.currentHealth = current_player.finalHealth
		Global.Player = current_player
		
		emit_signal("player_spawned", current_player)

func get_current_class():
	return player_class_scene
