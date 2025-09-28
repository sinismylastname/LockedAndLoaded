extends Button

func _ready():
	pressed.connect(_on_Button_pressed)

func _on_Button_pressed():
	AudioGlobal.play_click()
