extends Button

func _ready():
	pass

func _on_pressed() -> void:
	print("--- PlayButton Firing Global.game_started") # <-- ADD THIS
	Global.game_started.emit()
