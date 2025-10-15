extends Node2D

@onready var camera_node = $Camera2D
@onready var upgrade_ui_node = $upgradeMenu
@onready var wave_tracker = $WaveManager
@onready var player = $Player

func _ready():
	ClassManager.connect("player_spawned", Callable(self, "_on_player_spawned"))
	CRT.visible = Global.CRTEffect
	Global.reset_game()

func _on_player_spawned(player):
	Global.set_game_references(player, upgrade_ui_node)
	FortuneManager.set_game_references(player)
	UI_Global.set_game_references(player, camera_node)
