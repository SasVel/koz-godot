extends Node

@export var target : Node2D
@export var scale_speed = 2

@export var has_scale_y : bool = true
@export var scale_y = 0.5

@export var has_scale_x : bool = true
@export var scale_x = 0.5

@export var has_skew : bool = true
@export var skew_deg = 5
var default_scale
var default_position 

func _ready() -> void:
	default_scale = target.scale
	default_position = target.position
	if has_scale_y: tween_scale_y()
	if has_skew: tween_skew()
	await get_tree().create_timer(scale_speed).timeout
	if has_scale_x: tween_scale_x()

func tween_scale_y():
	var tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(target, "scale:y", default_scale.y + scale_y, scale_speed)
	tween.parallel().tween_property(target, "position:y",
		default_position.y - (scale_y * 300),
		scale_speed)

	tween.tween_property(target, "scale:y", default_scale.y, scale_speed)
	tween.parallel().tween_property(target, "position:y",
		default_position.y,
		scale_speed)

func tween_scale_x():
	var tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(target, "scale:x", default_scale.x + scale_x, scale_speed)
	tween.tween_property(target, "scale:x", default_scale.x, scale_speed)

func tween_skew():
	var tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(target, "skew", deg_to_rad(-skew_deg), scale_speed)
	tween.tween_property(target, "skew", deg_to_rad(skew_deg),
	 scale_speed).set_delay(scale_speed)
