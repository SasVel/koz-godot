extends ProgressBar
class_name EntityBar

@export var healthBarStyleBox : StyleBoxFlat
@export var blockBarStyleBox : StyleBoxFlat

func config(healthStat : Stat, blockStat : Stat):
	healthBarStyleBox.bg_color = Const.SECONDARY_COLOR
	%HealthLabel.label_settings.font_color = Const.SECONDARY_COLOR
	blockBarStyleBox.bg_color = Const.COMPLIMENTARY_COLOR
	%BlockLabel.label_settings.font_color = Const.COMPLIMENTARY_COLOR

	healthStat.max_stat_changed.connect(\
		func(_oldVal, newVal):
			self.max_value = newVal)

	healthStat.stat_changed.connect(\
		func(_oldVal, newVal):
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
	self.value = val
	%HealthLabel.text = str(val)

func update_block(val):
	%Divider.visible = val > 0
	%BlockLabel.visible = val > 0

	%BlockBar.value = val
	%BlockLabel.text = str(val)
