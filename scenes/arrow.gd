extends Sprite2D

var player = null
var next_tp_point = null

func _ready():
	Global.connect("player_changed", Callable(self, "_on_player_changed"))
	Global.connect("next_tp_point_changed", Callable(self, "_on_next_point_changed"))
	_on_player_changed(Global.Player)
	_on_next_point_changed(Global.next_tp_point)
	
func _on_player_changed(new_player):
	player = new_player

func _on_next_point_changed(new_point):
	next_tp_point = new_point
	
func _process(delta: float) -> void:
	#print(player)
	global_position = player.global_position
	if !next_tp_point:
		return
	else:
		rotation = (next_tp_point.global_position - global_position).angle() + PI/2
