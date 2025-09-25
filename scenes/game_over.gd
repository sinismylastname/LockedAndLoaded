extends CanvasLayer


func _ready() -> void:
	var Player = get_tree().get_root().find_child("Player", true, false)
	Player.connect("playerDied", _on_player_died)
	visible = false

func _on_player_died():
	visible = true
