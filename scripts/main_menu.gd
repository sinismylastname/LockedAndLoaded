extends Control

@onready var buttons_node : Control = $LAYER3/BUTTONS
@onready var fade_rect : ColorRect = $FadeRect
var original_pos
var buttons : Array
var parallax_strength := 0.05
var base_positions := {}
@onready var layers := [
	$LAYER3,
	$LAYER2,
	$LAYER1
]


func _ready() -> void:
	fade_rect.visible = true
	fade_rect.modulate.a = 1.0
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fade_tween.connect("finished", Callable(self, "_on_fade_finished"))
	
	$LAYER2/Title.position = Vector2(480.0, -138.0)
	var title_tween = create_tween()
	title_tween.tween_property($LAYER2/Title, "position", Vector2(486.0, 138.0), 0.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	
	AudioGlobal.play_main_menu()
	buttons = buttons_node.get_children()
	for button in buttons:
		button.add_theme_color_override("font_hover_color", Color(1.0, 0.876, 0.617, 1.0))
	add_hover_effects()
	slide_in_buttons()
	
	for layer in layers:
		if layer:
			base_positions[layer] = layer.position

func _on_fade_finished():
	fade_rect.queue_free()


func add_hover_effects():
	for button in buttons:
		button.connect("mouse_entered", Callable(self, "_on_button_hovered").bind(button))
		button.connect("mouse_exited", Callable(self, "_on_button_exited").bind(button))


func _on_button_hovered(button):
	var tween = get_tree().create_tween()
	original_pos = button.position
	tween.tween_property(button, "position", original_pos + Vector2(10, 0), 0.1)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	
func _on_button_exited(button):
	var tween = get_tree().create_tween()
	tween.tween_property(button, "position", original_pos, 0.1)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)


func slide_in_buttons():
	var delay_step = 0.3
	var base_offset = Vector2(-400, 0)
	var duration = 0.6

	for i in buttons.size():
		var button = buttons[i]
		var original = button.position
		button.position = original + base_offset

		var tween = get_tree().create_tween()
		tween.tween_interval(i * delay_step)
		tween.tween_property(button, "position", original, duration)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)


func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var center = get_viewport_rect().size / 2.0
	var offset_x = (mouse_pos.x - center.x) * parallax_strength

	for i in range(layers.size()):
		var layer = layers[i]
		if layer == null:
			continue
		var depth_factor = float(i) / layers.size()
		var base_pos = base_positions[layer]
		var target_x = base_pos.x + offset_x * (1.0 - depth_factor)
		
		var target_pos = Vector2(-target_x, base_pos.y)
		layer.position = layer.position.lerp(target_pos, delta * 5.0)
		

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
