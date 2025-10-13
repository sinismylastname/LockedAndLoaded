extends CanvasLayer

var sniper_class_path = "res://scenes/SniperPlayer.tscn"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	Global.connect("upgrade_continue", _upgrade_continue)
	print("init class change ui")

func _upgrade_continue(bool):
	print("gonna show up!!")
	if bool == true:
		if Global.currentLevel == 8:
			await get_tree().process_frame
			visible = true
			get_tree().paused = true

func _on_button_pressed() -> void:
	ClassManager.switch_class(sniper_class_path)
	get_tree().paused = false
	visible = false
