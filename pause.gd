extends CanvasLayer

var opened = false
var main_menu = preload("res://scenes/main_menu.tscn")

func _ready() -> void:
	visible = false
	opened = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and !opened:
		visible = true
		opened = true
		get_tree().paused = true
	elif Input.is_action_just_pressed("pause") and opened:
		visible = false
		opened = false
		get_tree().paused = false
		
func _on_unpause_btn_pressed() -> void:
	visible = false
	opened = false
	get_tree().paused = false

func _on_restart_pressed() -> void:
	visible = false
	opened = false
	Global.reset_game()

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
