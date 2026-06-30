extends Node

@export var target : Node2D 

var default_scale
var default_position

func play():
	default_position = target.global_position
	default_scale = target.scale

	var tween = create_tween()
	tween.tween_property(target, "scale", default_scale * 1.1, 0.1)
	tween.tween_property(target, "rotation_degrees", 8, 0.2)

	tween.tween_property(target, "rotation_degrees", 0, 0.15)
	tween.parallel().tween_property(target, "scale", default_scale, 0.15)
	await tween.finished
