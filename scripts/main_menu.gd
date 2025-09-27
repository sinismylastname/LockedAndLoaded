extends Control

@onready var playButton = $PlayButton
@onready var settingsButton = $SettingsButton
@onready var exitButton = $ExitButton

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
