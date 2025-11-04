extends Control

var steps = 0
@onready var label = $Label
@onready var image = $Image

func _ready():
	pass

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_next_pressed() -> void:
	steps += 1

func _on_prev_pressed() -> void:
	if steps <= 0:
		return
	else:
		steps -= 1

func _process(delta: float) -> void:
	if steps == 0:
		label.text = "Welcome to Locked and Loaded!"
		label.global_position = Vector2(258.0, 324.0)
	if steps == 1:
		label.text = "This tutorial will guide you through on how to play this game."
	if steps == 2:
		label.global_position = Vector2(284.0, 510.0)
		label.text = "You are locked in place! (hence, the title)"
		
	
