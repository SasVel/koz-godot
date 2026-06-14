extends MiniDisplay
class_name StatusEffDisplay

@export var is_colored_outline : bool = true
var data : StatusEffData

func config(eff_data : StatusEffData):
	data = eff_data
	var color = ObjManager.get_effect_color(data.type)
	self.texture = ObjManager.get_effect_sprite(data.type)
	self.modulate = color
	if is_colored_outline:
		%NumLabel.label_settings.outline_color = color
		%StacksLabel.label_settings.outline_color = color

	update(eff_data.duration)
	Game.add_status_eff_action(activate, true if data.source is Player else false)
	return self

func activate():
	await tween_activate()
	data.activate_eff()
	if data.duration == 0:
		delete(true)
	else:
		update(data.duration)

func update(num):
	%NumLabel.visible = num > 1
	if num == -1:
		super(8)
		%NumLabel.rotation_degrees = 90
	else:
		super(num)
		%NumLabel.rotation_degrees = 0

	update_stacks(data.stacks)

func update_stacks(stacks):
	%StacksLabel.visible = stacks > 1
	%StacksLabel.text = "x%s" % stacks

func delete(with_data : bool = false):
	Game.remove_status_eff_action(activate, true if data.source is Player else false)
	if with_data: data.delete()
	queue_free()
