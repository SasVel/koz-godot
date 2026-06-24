extends Node

@export var target : Node2D
@onready var settings : IdleAnimSettings

@onready var scale_y_tween : Tween
@onready var scale_x_tween : Tween
@onready var skew_tween : Tween

var default_scale
var default_position

func config(settings_ : IdleAnimSettings):
	settings = settings_

func _ready() -> void:
	default_scale = target.scale
	default_position = target.position
	start()

func start():
	if settings.has_scale_y: tween_scale_y()
	if settings.has_skew: tween_skew()
	await get_tree().create_timer(settings.scale_speed).timeout
	if settings.has_scale_x: tween_scale_x()

func stop():
	if scale_x_tween != null:
		scale_x_tween.stop()
	if scale_y_tween != null:
		scale_y_tween.stop()
	if skew_tween!= null:
		skew_tween.stop()

func tween_scale_y():
	scale_y_tween = create_tween()\
			.set_loops()\
			.set_ease(settings.ease_type)\
			.set_trans(settings.transition_type)

	scale_y_tween.tween_property(target, "scale:y", default_scale.y + settings.scale_y,
	 settings.scale_speed)
	if settings.is_scale_pos:
		scale_y_tween.parallel().tween_property(target, "position:y",
			default_position.y - (settings.scale_y * 300),
			settings.scale_speed)

	scale_y_tween.tween_property(target, "scale:y", default_scale.y, settings.scale_speed)
	if settings.is_scale_pos:
		scale_y_tween.parallel().tween_property(target, "position:y",
			default_position.y,
			settings.scale_speed)

func tween_scale_x():
	scale_x_tween = create_tween()\
			.set_loops()\
			.set_ease(settings.ease_type)\
			.set_trans(settings.transition_type)
	scale_x_tween.tween_property(target, "scale:x", default_scale.x + settings.scale_x,
	 settings.scale_speed)
	scale_x_tween.tween_property(target, "scale:x", default_scale.x, settings.scale_speed)

func tween_skew():
	skew_tween = create_tween()\
			.set_loops()\
			.set_ease(settings.ease_type)\
			.set_trans(settings.transition_type)
	skew_tween.tween_property(target, "skew", deg_to_rad(settings.skew_deg * -1),
	 settings.scale_speed)
	skew_tween.tween_property(target, "skew", deg_to_rad(settings.skew_deg),
	 settings.scale_speed).set_delay(settings.scale_speed)
