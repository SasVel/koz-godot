extends MiniDisplay
class_name ActionMiniDisplay

@export var is_colored_outline : bool = true
@onready var data : CardData

func config(data_ : CardData):
	data = data_

	var color = ObjManager.get_action_color(data.actionType)
	self.texture = ObjManager.get_action_mini_sprite(data.actionType)

	self.modulate = color
	if is_colored_outline:
		%NumLabel.label_settings.outline_color = color
	data.source.status_effects_changed.connect(\
		func(_x): update(data.get_generic_value()))

	update(data.get_generic_value())
	return self

func update(num):
	if data.isOffensive:
		num = data.source.process_damage_outgoing(num)
	super(num)
