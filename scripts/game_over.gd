extends CanvasLayer

var Player = null

func _ready() -> void:
	Player = get_tree().get_root().find_child("Player", true, false)
	ClassManager.connect("player_spawned", Callable(self, "_on_player_spawned"))
	visible = false

func _on_player_spawned(player):
	player.connect("playerDied", Callable(self, "_on_player_died"))

func _on_player_died():
	visible = true
	$Menu.grab_focus()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_play_again_pressed() -> void:
	Global.reset_game()
	visible  = false
