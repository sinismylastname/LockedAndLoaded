extends CanvasLayer


func _ready() -> void:
	var Player = get_tree().get_root().find_child("Player", true, false)
	Player.connect("playerDied", _on_player_died)
	visible = false

func _on_player_died():
	visible = true

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
