extends Control
class_name ArcadeGameShell

@export var main_3d_scene_path: String = "res://scenes/Main3DScene.tscn"
@onready var menu_screen = $MainMenu
@onready var gameplay_screen = $Game
@onready var settings_screen = $Settings

func _ready():
	pause_2d_game()
	show_menu()

func pause_2d_game():
	set_process(false)
	set_physics_process(false)

func resume_2d_game():
	set_process(true)
	set_physics_process(true)
	#get_tree().paused = false 
	
func show_menu():
	menu_screen.show()
	gameplay_screen.hide()
	settings_screen.hide()

func start_game():
	menu_screen.hide()
	gameplay_screen.show()
	settings_screen.hide()

func show_settings():
	menu_screen.hide()
	gameplay_screen.hide()
	settings_screen.show()

func quit_to_3d_world():
	pause_2d_game()
	var main_scene = load(main_3d_scene_path)
	get_tree().change_scene_to_packed(main_scene)
