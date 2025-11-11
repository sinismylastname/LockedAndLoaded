extends CanvasLayer

var screen_width
var mouse_x
var menu_threshold = 1152
var close_threshold = 800
var opened
var original_pos = Vector2(1200.0, 35.0)
var opened_pos = Vector2(865.0, 35.0)
var action = "closed_menu"

@onready var sidebar_panel = $SidebarRoot/Panel
@onready var tp_point_scene = preload("res://scenes/tp_point.tscn")

func _ready() -> void:
	$sidebar_indicator.visible = true
	screen_width = DisplayServer.screen_get_size().x
	sidebar_panel.position = original_pos
	
func open_menu():
	$sidebar_indicator.visible = false
	var tween = create_tween()
	$SidebarRoot/Panel/SidebarContainer/upgradeMenu/Power/AddBulletPower.grab_focus()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).tween_property(sidebar_panel, "position", opened_pos-Vector2(20, 0), 0.1)
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).tween_property(sidebar_panel, "position", opened_pos+Vector2(10, 0), 0.05)
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).tween_property(sidebar_panel, "position", opened_pos, 0.15)
	return

func close_menu():
	get_viewport().gui_release_focus()
	$sidebar_indicator.visible = true
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).tween_property(sidebar_panel, "position", original_pos, 0.3)
	return
	
func _process(delta: float) -> void:
	mouse_x = get_viewport().get_mouse_position().x
	if mouse_x > menu_threshold and !opened:
		print("should open menu")
		opened = true
		open_menu()
	elif mouse_x < close_threshold and opened:
		print("close menu")
		opened = false
		close_menu()
	elif Input.is_action_just_pressed("open_menu") and !opened and action == "closed_menu":
		print("should open menu")
		opened = true
		open_menu()
		action = "open_menu"
	elif Input.is_action_just_pressed("open_menu") and opened and action == "open_menu":
		print("close menu")
		opened = false
		close_menu()
		action = "closed_menu"
	#print(mouse_x)

func _on_tppointspawn_pressed() -> void:
	if Global.tp_point_possible():
		var new_tp_point = tp_point_scene.instantiate()
		new_tp_point.set_spawn(Vector2(400, 400))
		get_tree().current_scene.add_child(new_tp_point)
		
		Global.tp_point_array.append(new_tp_point)
		new_tp_point.index = Global.tp_point_array.size() - 1
