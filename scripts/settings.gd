extends Control

@onready var volumeSlider = $VolumeSlider

func _ready():
	var master_bus_idx = AudioServer.get_bus_index("Master")
	var initialVolume = AudioServer.get_bus_volume_db(master_bus_idx)
	volumeSlider.value = initialVolume

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	var currentMode = DisplayServer.window_get_mode()
	
	if currentMode != DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_crt_button_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		Global.CRTEffect = true
	elif toggled_on == false:
		Global.CRTEffect = false
