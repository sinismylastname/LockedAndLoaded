extends Node2D

@onready var camera_node = $Camera2D
@onready var upgrade_ui_node = $upgradeMenu
@onready var wave_tracker = $WaveManager

func _ready():
	CRT.visible = Global.CRTEffect
	Global.reset_game()

func _on_player_spawned(player):
	Global.set_game_references(player, $upgradeMenu)
	FortuneManager.set_game_references(player)
	UI_Global.set_game_references(player, $Camera2D)
