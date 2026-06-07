extends Node

@export var target : Node2D
@onready var settings : IdleAnimSettings

var default_scale
var default_position 

func config(settings_ : IdleAnimSettings):
	settings = settings_

func _ready() -> void:
	default_scale = target.scale
	default_position = target.position
	if settings.has_scale_y: tween_scale_y()
	if settings.has_skew: tween_skew()
	await get_tree().create_timer(settings.scale_speed).timeout
	if settings.has_scale_x: tween_scale_x()

func tween_scale_y():
	var tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(target, "scale:y", default_scale.y + settings.scale_y, settings.scale_speed)
	tween.parallel().tween_property(target, "position:y",
		default_position.y - (settings.scale_y * 300),
		settings.scale_speed)

	tween.tween_property(target, "scale:y", default_scale.y, settings.scale_speed)
	tween.parallel().tween_property(target, "position:y",
		default_position.y,
		settings.scale_speed)

func tween_scale_x():
	var tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(target, "scale:x", default_scale.x + settings.scale_x,
	 settings.scale_speed)
	tween.tween_property(target, "scale:x", default_scale.x, settings.scale_speed)

func tween_skew():
	var tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(target, "skew", deg_to_rad(settings.skew_deg * -1),
	 settings.scale_speed)
	tween.tween_property(target, "skew", deg_to_rad(settings.skew_deg),
	 settings.scale_speed).set_delay(settings.scale_speed)
