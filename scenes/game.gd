extends Node2D

@onready var player_node = $Player
@onready var upgrade_ui_node = $upgradeMenu

func _ready():
	Global.set_game_references(player_node, upgrade_ui_node)
