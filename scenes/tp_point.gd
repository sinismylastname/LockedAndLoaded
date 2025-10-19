extends Area2D

var is_dragging = false
var mouse_offset = Vector2.ZERO
var target_pos = Vector2.ZERO
static var active_dragger: Area2D = null

var index: int
var stored_position: Vector2

func _ready():
	input_pickable = true
	set_process_input(true)

func set_spawn(spawn_location: Vector2):
	target_pos = spawn_location

func _process(delta):
	if is_dragging:
		target_pos = get_global_mouse_position() + mouse_offset
	global_position = lerp(global_position, target_pos, 0.2)

func _input(event):
	if is_dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
		is_dragging = false
		active_dragger = null

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if active_dragger == null:
			active_dragger = self
			is_dragging = true
			mouse_offset = global_position - get_global_mouse_position()
