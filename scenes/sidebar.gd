extends CanvasLayer

var screen_width
var mouse_x
var menu_threshold = 900
var opened
var original_pos = Vector2(1200.0, 0.0)
var opened_pos = Vector2(900.0, 0.0)

@onready var sidebar_panel = $SidebarRoot/Panel

func _ready() -> void:
	screen_width = DisplayServer.screen_get_size().x
	sidebar_panel.position = Vector2(1200.0, 0.0)
	
func open_menu():
	var tween = create_tween()
	tween.tween_property(sidebar_panel, "position", opened_pos, 0.5)

func close_menu():
	var tween = create_tween()
	tween.tween_property(sidebar_panel, "position", original_pos, 0.5)
	
func _process(delta: float) -> void:
	mouse_x = get_viewport().get_mouse_position().x
	if mouse_x > menu_threshold and !opened:
		print("should open menu")
		opened = true
		open_menu()
	elif mouse_x < menu_threshold and opened:
		print("close menu")
		opened = false
		close_menu()
	#print(mouse_x)
