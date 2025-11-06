extends Control

var steps = 0
@onready var label = $Label
@onready var image = $Image
@onready var img1 = preload("res://images/img1.png")
@onready var img2 = preload("res://images/img2.png")

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
		label.global_position = Vector2(258.0, 300.0)
		image.visible = false
	if steps == 1:
		label.text = "This tutorial will guide you through on how to play this game."
		label.global_position = Vector2(258.0, 288.0)
		image.visible = false
	if steps == 2:
		label.global_position = Vector2(284.0, 510.0)
		label.text = "You are locked in place! (hence, the title)"
		image.visible = true
		image.texture = img1
	if steps == 3:
		label.text = "The only way you can move yourself is by rotation."
		image.texture = img2
	if steps == 4:
		label.global_position = Vector2(284.0, 490.0)
		label.text = "To defend yourself, you automatically shoot a bullet between short intervals."
		
	
