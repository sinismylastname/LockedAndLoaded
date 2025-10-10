extends CanvasLayer

var sniper_class_path = "res://scenes/SniperPlayer.tscn"


func _on_button_pressed() -> void:
	ClassManager.switch_class(sniper_class_path)
