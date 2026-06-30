extends ProgressBar
class_name EntityBar

@export var healthBarStyleBox : StyleBoxFlat
@export var blockBarStyleBox : StyleBoxFlat

var default_position
var default_scale

func config(healthStat : Stat, blockStat : Stat):
	healthBarStyleBox.bg_color = Const.SECONDARY_COLOR
	%HealthLabel.label_settings.font_color = Const.SECONDARY_COLOR
	blockBarStyleBox.bg_color = Const.COMPLIMENTARY_COLOR
	%BlockLabel.label_settings.font_color = Const.COMPLIMENTARY_COLOR

	healthStat.max_stat_changed.connect(\
		func(_oldVal, newVal):
			self.max_value = newVal)

	healthStat.stat_changed.connect(\
		func(oldVal, newVal):
			if oldVal > newVal:
				tween_hit()
			update_health(newVal))

	blockStat.max_stat_changed.connect(\
		func(_oldVal, newVal):
			%BlockBar.max_value = newVal)

	blockStat.stat_changed.connect(\
		func(_oldVal, newVal):
			update_block(newVal))

	self.max_value = healthStat.maxValue
	update_health(healthStat.value)

	update_block(blockStat.value)
	%BlockBar.max_value = blockStat.maxValue

func update_health(val):
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "value", val, 0.1)
	%HealthLabel.text = str(val)

func update_block(val):
	%Divider.visible = val > 0
	%BlockLabel.visible = val > 0

	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%BlockBar, "value", val, 0.1)
	%BlockLabel.text = str(val)

func tween_hit():
	default_position = self.position
	default_scale = self.scale
	var offset : int = 5

	var offset_positions : Array[Vector2] = []
	for i in range(randi_range(3, 6)):
		offset_positions.append(Vector2(randf_range(-offset, offset), randf_range(-offset, offset)))

	var tween = create_tween()
	tween.tween_property(self, "scale", default_scale * 1.1, 0.1)
	for pos in offset_positions:
		tween.tween_property(self, "position", default_position + pos, 0.1)
		tween.tween_property(self, "position", default_position, 0.1)

	tween.tween_property(self, "scale", default_scale, 0.1)
	await tween.finished
