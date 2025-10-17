extends Area2D

var is_dragging = false
var mouse_offset = Vector2.ZERO

func _ready():
	input_pickable = true  # this is crucial in Godot 4

func follow_mouse():
	global_position = get_global_mouse_position() + mouse_offset

func _process(delta):
	if is_dragging:
		follow_mouse()


func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print("entered mouse")
	#if !Global.is_intermission:
	#	return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			mouse_offset = global_position - get_global_mouse_position()
		else:
			is_dragging = false
