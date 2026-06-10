extends MiniDisplay
class_name StatusEffDisplay

@export var is_colored_outline : bool = true
var data : StatusEffData

func config(eff_data : StatusEffData):
	data = eff_data
	Game.status_effects_actions.append(activate)
	var color = ObjManager.get_effect_color(data.type)
	self.texture = ObjManager.get_effect_sprite(data.type)
	self.modulate = color
	if is_colored_outline:
		%NumLabel.label_settings.outline_color = color
		%StacksLabel.label_settings.outline_color = color

	update(eff_data.duration)
	return self

func activate():
	await tween_activate()
	data.activate()
	if data.duration == 0:
		delete()
	else:
		update(data.duration)

func update(num):
	if num == -1:
		%NumLabel.text = ""
	else:
		super(num)

	update_stacks(data.stacks)

func update_stacks(stacks):
	if stacks <= 1: return
	%StacksLabel.text = "x%s" % stacks

func delete():
	data.source.remove_status_effect(data)
	Game.status_effects_actions.erase(activate)
	queue_free()
