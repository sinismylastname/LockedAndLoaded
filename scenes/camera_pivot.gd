extends Node3D

@export var bob_speed: float = 12.0
@export var bob_amount_y: float = 0.03
@export var bob_amount_z: float = 0.03

var time_elapsed: float = 0.0
@onready var player = get_parent()

func _process(delta: float):
	var horizontal_velocity = Vector2(player.velocity.x, player.velocity.z).length()
	var movement_ratio = min(1.0, horizontal_velocity / player.SPEED) 
	if movement_ratio > 0.05:
		time_elapsed += delta * bob_speed * movement_ratio
	else:
		time_elapsed = lerp(time_elapsed, floor(time_elapsed / PI) * PI, delta * 5.0) 
	var bob_y = sin(time_elapsed) * bob_amount_y * movement_ratio
	var bob_z = cos(time_elapsed / 2.0) * bob_amount_z * movement_ratio 
	var default_pos = Vector3(0, 0, 0)    
	position = default_pos + Vector3(0, bob_y, bob_z)
