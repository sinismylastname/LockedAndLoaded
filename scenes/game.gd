extends Node2D

@onready var player_node = $Player
@onready var camera_node = $Camera2D
@onready var upgrade_ui_node = $upgradeMenu
@onready var wave_tracker = $WaveManager

func _ready():
	ClassManager.connect("player_spawned", Callable(self, "_on_player_spawned"))
	
	var base_class_path = "res://scenes/player.tscn"
	ClassManager.spawn_player(base_class_path)
	

func _on_player_spawned(player):
	Global.set_game_references(player, $upgradeMenu)
	FortuneManager.set_game_references(player)
	UI_Global.set_game_references(player, $Camera2D)
