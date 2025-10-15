extends Node3D 

@export var main_camera: Camera3D           # Drag your main 3D camera here.
@export var target_screen_mesh: MeshInstance3D  # Drag the ScreenOverlay mesh here.
@export var fullscreen_2d_layer: CanvasLayer # Drag the hidden CanvasLayer here.
@export var arcade_game_shell: ArcadeGameShell # Drag the ArcadeGameShell instance under the CanvasLayer here.

const TRANSITION_DURATION = 2
const DISTANCE_OFFSET = 0.1

func _input(event):
	if event.is_action_pressed("Interact"): 
		start_transition_to_2d()

func start_transition_to_2d():
	var screen_global_transform = target_screen_mesh.global_transform
	var target_position = screen_global_transform.origin - screen_global_transform.basis.z * DISTANCE_OFFSET
	var target_transform = Transform3D(screen_global_transform.basis, target_position)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(main_camera, "global_transform", target_transform, TRANSITION_DURATION)
	tween.tween_callback(cut_to_2d_and_start_game)

func cut_to_2d_and_start_game():
	main_camera.visible = false
	target_screen_mesh.get_parent().visible = false 
	fullscreen_2d_layer.visible = true
	arcade_game_shell.resume_2d_game()


#func is_player_close_enough() -> bool:
	
