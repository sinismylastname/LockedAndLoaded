extends CanvasLayer

func _ready():
	visible = false
	Global.game_started.connect(_on_game_started)

func _on_game_started():
	if Global.CRTEffect == true:
		visible = true
	elif Global.CRTEffect == false:
		visible = false
