extends Node

@export var target : Node2D 

var default_scale
var default_position

func play():
	default_position = target.global_position
	default_scale = target.scale

	var offset_positions : Array[Vector2] = []
	for i in range(randi_range(2, 5)):
		offset_positions.append(Vector2(randf_range(-10, 10), randf_range(-10, 10)))

	var tween = create_tween()
	tween.tween_property(target, "scale", default_scale * 1.1, 0.1)
	for pos in offset_positions:
		tween.tween_property(target, "global_position", default_position + pos, 0.1)
		tween.tween_property(target, "global_position", default_position, 0.1)

	tween.tween_property(target, "scale", default_scale, 0.1)
	await tween.finished
