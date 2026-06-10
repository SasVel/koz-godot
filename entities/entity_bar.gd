extends ProgressBar
class_name EntityBar

func config(healthStat : Stat, blockStat : Stat):
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

	update_health(healthStat.value)
	self.max_value = healthStat.maxValue

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
