extends "res://scripts/enemy.gd"
@onready var regular_enemy_scene = preload("res://scenes/enemy.tscn")
@onready var speedy_enemy_scene = preload("res://scenes/fast_enemy.tscn")
@onready var tanky_enemy_scene = preload("res://scenes/tanky_enemy.tscn")
@onready var shooter_enemy_scene = preload("res://scenes/shooter_enemy.tscn")

var REGULAR_CHANCE = 0.25
var SPEEDY_CHANCE = 0.25
var TANKY_CHANCE = 0.25
var SHOOTER_CHANCE = 0.25

func _ready():
	super._ready()
	health = 1
	speed = randf_range(Global.enemySpeed/2, Global.enemySpeed*1.5)

func enemyDied():
	Global.addXP(5)
	Global.emit_signal("xp_changed", 5)
	
	var roll = randf()
	
	if roll < SPEEDY_CHANCE:
		_spawn_enemy(speedy_enemy_scene)
	elif roll < SPEEDY_CHANCE + TANKY_CHANCE:
		_spawn_enemy(tanky_enemy_scene)
	elif roll < SPEEDY_CHANCE + TANKY_CHANCE + REGULAR_CHANCE:
		_spawn_enemy(regular_enemy_scene)
	else:
		_spawn_enemy(shooter_enemy_scene)
	await get_tree().process_frame
	queue_free.call_deferred()
	Global.decrease_enemy_count()
	
func _spawn_enemy(scene):
	var new_enemy = scene.instantiate()
	new_enemy.global_position = global_position
	get_tree().current_scene.add_child(new_enemy)
	return
