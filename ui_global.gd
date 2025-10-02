extends Node
var Player = null
var Camera = null
var shake_power = 0
var time_left = 0
var original_offset = Vector2(0, 0)
var original_rotation = 0
var random_offset
var random_rotation
var max_offset = Vector2(100, 75)
var max_rotation = 0.1
var decay = 0.08

func set_game_references(player_node, camera_node):
	Player = player_node
	Camera = camera_node

func add_camera_shake(power, duration):
	original_offset = Camera.offset
	original_rotation = Camera.rotation
	shake_power = shake_power + power
	time_left = time_left + duration
	
func _process(delta: float) -> void:
	if Camera == null: 
		return #ok so this is so that the game doesn't crash tf out bruh bc like the player isnt instantiated when the game starts, so it's trying to find something nonexistant
	if time_left > 0:
		time_left -= delta
		random_offset = Vector2(randf_range(-shake_power, shake_power), randf_range(-shake_power, shake_power))
		random_rotation = randf_range(-shake_power, shake_power)
		Camera.offset.x = clamp(0, original_offset.x + random_offset.x, max_offset.x) #ok i split into x and y because im literally far too lazy to do something that would save me a line of code. lets be honest now.
		Camera.offset.y = clamp(0, original_offset.y + random_offset.y, max_offset.y)
		Camera.rotation = clamp(0, original_rotation + random_rotation, max_rotation)
		random_offset *= decay
		random_rotation *= decay
	else: 
		lerpf(Camera.offset.x, original_offset.x, decay) #bro same thing as above. i aint doing allat
		lerpf(Camera.offset.y, original_offset.y, decay)
		lerpf(Camera.rotation, original_rotation, decay)
	
