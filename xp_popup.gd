extends Label

func _ready():
	modulate = Color(1, 1, 0.3)
	scale = Vector2.ONE * 0.8
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 40, 1)
	tween.parallel().tween_property(self, "modulate:a", 0, 1)
	await tween.finished
	queue_free()
