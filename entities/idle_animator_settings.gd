extends Resource
class_name IdleAnimSettings

@export var ease_type = Tween.EASE_IN_OUT
@export var transition_type = Tween.TRANS_CUBIC

@export var scale_speed = 2
@export var is_scale_pos : bool = true

@export var has_scale_y : bool = true
@export var scale_y = 0.5

@export var has_scale_x : bool = true
@export var scale_x = 0.5

## Also used for rotation for controls.
@export var has_skew : bool = true
@export var skew_deg = 5
