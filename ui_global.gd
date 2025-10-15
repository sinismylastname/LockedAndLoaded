extends Node

@onready var noise = FastNoiseLite.new()

var Player = null
var Camera = null
var shake_exponent = 2
var shake_amount = 0.0
var max_offset = Vector2(100, 75) 
var max_rotation = 0.1 #radians
var decay = 0.8
var noise_y = 0.0

func _ready():
	randomize()
	noise.seed = randi()
	noise.frequency = 2.0
	noise.fractal_octaves = 2

func set_game_references(player_node, camera_node):
	Player = player_node
	Camera = camera_node

func add_shake(power):
	shake_amount = min(shake_amount + power, 1.0)

func shake() -> Array:
	var amount = pow(shake_amount, shake_exponent)
	var offset = Vector2(
		max_offset.x * amount * noise.get_noise_1d(noise_y + 100.0),
		max_offset.y * amount * noise.get_noise_1d(noise_y + 200.0)
	)
	var rot = max_rotation * amount * noise.get_noise_1d(noise_y)
	return [offset, rot]

func _process(delta: float) -> void:
	if not Player or not Camera:
		return

	var offset = Vector2.ZERO
	var rot = 0.0

	if shake_amount > 0.0:
		print("shake_amount:", shake_amount)
		shake_amount = max(shake_amount - decay * delta, 0)
		var result = shake()
		offset = result[0]
		rot = result[1]
		noise_y += delta * 20.0
	
	if Player:
		Camera.global_position = Player.global_position + offset
	
