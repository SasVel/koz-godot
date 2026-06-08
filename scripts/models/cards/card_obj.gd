extends DragObject
class_name CardObj

@export var focus_tween_speed = 0.2
@export var focus_scale = 1.2
@export var cardBack : TextureRect
var focus_card_pos_y = self.position.y - (self.size.y * 0.8)
@onready var default_pos = self.position
@onready var default_rot = self.rotation

@onready var data : CardData

@onready var isOn : bool = true :
	set(val):
		cardBack.modulate = Color.WHITE if val else Color("b1b1b1")
		isOn = val

@onready var isTweening : bool = false

func config(data_ : CardData):
	data = data_
	data.changed_state.connect(func(x): isOn = x)
	if data.isOn != null:
		isOn = data.isOn

	var image : Texture2D
	var title_text : String
	match data.type:
		Const.CardTypes.ACTION:
			title_text = Const.Actions.keys()[data.actionType]
			image = ObjManager.get_action_sprite(data.actionType)
			%CardIconRect.modulate = Const.ACTION_COLOR
		Const.CardTypes.WEAPON:
			title_text = Const.Weapons.keys()[data.weaponType]
			image = ObjManager.get_weapon_sprite(data.weaponType)
			%CardIconRect.modulate = Const.TOOL_COLOR
		Const.CardTypes.SHIELD:
			title_text = Const.Shields.keys()[data.shieldType]
			image = ObjManager.get_shield_sprite(data.shieldType)
			%CardIconRect.modulate = Const.TOOL_COLOR

	%TitleLabel.text = UIHelper.pascal_to_readable_text(title_text)
	%DescLabel.text = data.generate_desc()
	%CardIconRect.texture = image 
	%TempoDisplay.config(Const.ACTION_COLOR, data.tempoCost, data.tempo_changed)
	return self

func set_defaults():
	default_pos = self.position
	default_rot = self.rotation

func _get_drag_data(at_position):
	if !isOn: return
	return super(at_position)

func _on_focus_entered() -> void:
	self.z_index = 1
	scale_on_focus(true)
	move_on_focus(true)

func _on_focus_exited() -> void:
	self.z_index = 0
	scale_on_focus(false)
	move_on_focus(false)

func scale_on_focus(on_off : bool):
	if isTweening: return
	var tween = create_tween()
	if on_off:
		tween.tween_property(self, "scale", Vector2(focus_scale, focus_scale), focus_tween_speed)
	else:
		tween.tween_property(self, "scale", Vector2(1, 1), focus_tween_speed)

func move_on_focus(on_off : bool):
	if isTweening: return
	var tween = create_tween()
	isTweening = true
	if on_off:
		tween.tween_property(self, "position:y", focus_card_pos_y,
		 focus_tween_speed).from(0)
		tween.parallel().tween_property(self, "rotation_degrees", 0, focus_tween_speed)
	else:
		tween.tween_property(self, "position", default_pos, focus_tween_speed)
		tween.parallel().tween_property(self, "rotation", default_rot,
		 focus_tween_speed)
	await tween.finished
	isTweening = false
