extends DragObject
class_name CardObj

@export var focus_tween_speed = 0.2
@export var focus_scale = 1.2
@export var cardBack : TextureRect
@onready var default_pos = self.position
@onready var default_rot = self.rotation

@onready var data : CardData

@onready var isOn : bool = true :
	set(val):
		cardBack.modulate = Color.WHITE if val else Color("b1b1b1")
		if val and curr_tween_state != TweenState.None:
			tween_idle(true)
		else:
			tween_idle(false)

		isOn = val

enum TweenState {
	None, # Used for external animations.
	Idle,
	Focus,
	Anim
}

@onready var curr_tween_state : TweenState = TweenState.None:
	set(val):
		match val:
			TweenState.None:
				isFocusTweening = false
				isAnimTweening = false
				tween_focus(false)
				tween_idle(false)
			TweenState.Idle:
				isFocusTweening = false
				isAnimTweening = false
				tween_focus(false)
				tween_idle(true)
			TweenState.Focus:
				isAnimTweening = false
				tween_idle(false)
				tween_focus(true)
				isFocusTweening = true
			TweenState.Anim:
				isFocusTweening = false
				isAnimTweening = true
				tween_idle(false)
		curr_tween_state = val

@onready var isLoot : bool = false
@onready var isFocusTweening : bool = false
@onready var isAnimTweening : bool = false

var focus_card_pos_y : float
var pre_activation_position : Vector2
var pre_activation_rot : float
var pre_activation_scale : Vector2

func config(data_ : CardData):
	data = data_
	data.changed_state.connect(func(x): isOn = x)
	data.card_object = self
	if data.isOn != null:
		isOn = data.isOn

	var image : Texture2D
	var title_text : String
	match data.type:
		Const.CardTypes.ACTION:
			title_text = Const.Actions.keys()[data.actionType]
			image = ObjManager.get_action_sprite(data.actionType)
			%CardIconRect.self_modulate = Const.COMPLIMENTARY_COLOR
		Const.CardTypes.WEAPON:
			title_text = Const.Weapons.keys()[data.weaponType]
			image = ObjManager.get_weapon_sprite(data.weaponType)
			%CardIconRect.self_modulate = Const.COMPLIMENTARY_COLOR
		Const.CardTypes.SHIELD:
			title_text = Const.Shields.keys()[data.shieldType]
			image = ObjManager.get_shield_sprite(data.shieldType)
			%CardIconRect.self_modulate = Const.COMPLIMENTARY_COLOR

	cardBack.self_modulate = Const.BACKGROUND_LIGHTER_COLOR
	%TitleLabel.text = UIHelper.pascal_to_readable_text(title_text)
	set_generate_description()
	data.update_status.connect(set_generate_description)
	%CardIconRect.texture = image
	%CardIconShadow.texture = image
	%TempoDisplay.config(Const.ACCENT_COLOR, data.tempoCost, data.tempo_changed)
	data.tempo_changed.connect(func(_x, y): %TempoDisplay.update(y))
	return self

func _ready() -> void:
	curr_tween_state = TweenState.None
	if focus_scale == null: focus_scale = 1.2
	focus_card_pos_y = get_viewport_rect().size.y - (self.custom_minimum_size.y * focus_scale + 10)

func set_generate_description():
	%DescLabel.text = data.generate_desc()

func change_opacity(val : float):
	cardBack.modulate.a = val

func set_defaults():
	default_pos = self.position
	default_rot = self.rotation

func _get_drag_data(at_position):
	if !isOn: return
	return super(at_position)

func _on_focus_entered() -> void:
	if Game.is_object_dragged: return
	self.z_index = 1
	SFX.play(SFX.Sounds.CardFlick)
	curr_tween_state = TweenState.Focus

func _on_focus_exited() -> void:
	self.z_index = 0
	curr_tween_state = TweenState.Idle

func tween_focus(on_off : bool):
	scale_on_focus(on_off)
	move_on_focus(on_off)

func scale_on_focus(on_off : bool):
	if isFocusTweening: return
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	if on_off:
		tween.tween_property(self, "scale", Vector2(focus_scale, focus_scale), focus_tween_speed)
	else:
		tween.tween_property(self, "scale", Vector2(1, 1), focus_tween_speed)

func move_on_focus(on_off : bool):
	if isFocusTweening or isLoot: return
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	if on_off:
		tween.tween_property(self, "global_position:y", focus_card_pos_y,
		 focus_tween_speed).from(self.global_position.y)
		tween.parallel().tween_property(self, "global_position:x", get_global_mouse_position().x - (self.size.x / 2), focus_tween_speed)
		tween.parallel().tween_property(self, "rotation_degrees", 0, focus_tween_speed)
	else:
		tween.tween_property(self, "position", default_pos, focus_tween_speed)
		tween.parallel().tween_property(self, "rotation", default_rot,
		 focus_tween_speed)
	await tween.finished

var idle_tween : Tween
func tween_idle(on_off : bool):
	if idle_tween != null:
		if idle_tween.is_running() and on_off:
			return

		if !on_off:
			idle_tween.stop()
			idle_tween.kill()
			self.offset_transform_position = Vector2.ZERO
			self.offset_transform_rotation = deg_to_rad(0)
			return

	if !on_off: return

	var rand_offset = randi_range(5, 10)
	var rand_rotation = deg_to_rad(randi_range(1, 3))
	var duration : float = randf_range(5, 8)
	_create_idle_tween()

	idle_tween.tween_property(self, "offset_transform_position:y", -rand_offset, duration / 2)
	idle_tween.parallel().tween_property(self, "offset_transform_rotation", -rand_rotation, duration / 2)

	idle_tween.tween_property(self, "offset_transform_position:y", rand_offset, duration / 2)
	idle_tween.parallel().tween_property(self, "offset_transform_rotation", rand_rotation, duration / 2)

func _create_idle_tween(is_looping : bool = true):
	idle_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	if is_looping:
		idle_tween.set_loops()

func animate_pre_activation(drop_position):
	# Setup
	pre_activation_position = self.global_position
	pre_activation_rot = self.rotation
	pre_activation_scale = self.scale
	self.z_index = 100

	# Tween move to center and scale up
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", (get_viewport_rect().size / 2) - self.size / 2, 0.5).from(drop_position)
	tween.parallel().tween_property(self, "rotation_degrees", 0, 0.5)
	tween.parallel().tween_property(self, "scale", self.scale * 1.1, 0.5)

	tween.parallel().tween_property(cardBack, "self_modulate:a", 0, 0.5)
	tween.parallel().tween_property(%TitleContainer, "modulate:a", 0, 0.5)
	tween.parallel().tween_property(%TempoDisplay, "modulate:a", 0, 0.5)
	tween.parallel().tween_property(%DescLabel, "self_modulate:a", 0, 0.5)

	tween.tween_property(self, "scale", self.scale * 1.3, 0.1)
	await tween.finished
	# Inst and tween effect trails.
	for comp in data.get_components():
		await UIHelper.tween_eff_trails(self.global_position + (cardBack.size / 2), comp)

	await get_tree().create_timer(0.3).timeout

func animate_post_activation():
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", pre_activation_position, 0.5)
	tween.parallel().tween_property(self, "rotation", pre_activation_rot, 0.5)
	tween.parallel().tween_property(self, "scale", pre_activation_scale, 0.5)

	tween.parallel().tween_property(cardBack, "self_modulate:a", 1, 0.5)
	tween.parallel().tween_property(%TitleContainer, "modulate:a", 1, 0.5)
	tween.parallel().tween_property(%TempoDisplay, "modulate:a", 1, 0.5)
	tween.parallel().tween_property(%DescLabel, "self_modulate:a", 1, 0.5)

	await tween.finished
	self.z_index = 0

func activate(drop_position : Vector2 = self.global_position, deduct_tempo : bool = true):
	Game.event_queue.append(Callable(self, "activation_sequence").bindv([drop_position, deduct_tempo]))

func activation_sequence(drop_position : Vector2 = self.global_position, deduct_tempo : bool = true):
	curr_tween_state = TweenState.Anim
	await animate_pre_activation(drop_position)
	data.activate(deduct_tempo)
	if self.is_queued_for_deletion(): return
	await animate_post_activation()
	curr_tween_state = TweenState.Idle

func _can_drop_data(_at_position: Vector2, drop_data: Variant) -> bool:
	return drop_data["object"].isLoot

func _drop_data(_at_position: Vector2, drop_data: Variant) -> void:
	if data.source == null: return
	data.source.replace_action_hand(drop_data["object"].data.duplicate(), self.data, true)
	drop_data["object"].queue_free()
