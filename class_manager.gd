extends Node

var current_player : Node
var player_class_scene : PackedScene

func _ready():
	var base_class_path = "res://scenes/player.tscn"
	

func spawn_player(path):
	player_class_scene = load(path)
	current_player = player_class_scene.instantiate()
	
	var spawn_point = get_node_or_null("SpawnPoint")
	if spawn_point:
		current_player.global_position = spawn_point.global_position
	else:
		current_player.global_position = Vector2(576.0, 323.0)
		
	add_child(current_player)

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

func get_current_class():
	return player_class_scene
