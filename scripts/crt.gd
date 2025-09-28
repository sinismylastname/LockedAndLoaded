extends CanvasLayer

func _ready():
	visible = false
	Global.game_started.connect(_on_game_started)

func _on_game_started():
	print("--- CRT Node Received signal. Setting visible = true")
	visible = true
