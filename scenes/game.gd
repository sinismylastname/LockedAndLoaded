extends Node2D

@onready var player_node = $Player
@onready var camera_node = $Camera2D
@onready var upgrade_ui_node = $upgradeMenu
@onready var wave_tracker = $WaveManager

func _ready():
	Global.connect("wave_started", Callable(FortuneManager, "_bushmanShowsUp"))
	Global.set_game_references(player_node, upgrade_ui_node)
	FortuneManager.set_game_references(player_node)
	UI_Global.set_game_references(player_node, camera_node)
