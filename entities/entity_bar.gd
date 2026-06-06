extends ProgressBar

func config(healthStat : Stat, blockStat : Stat):
	healthStat.max_stat_changed.connect(\
		func(_oldVal, newVal):
			self.max_value = newVal)

	healthStat.stat_changed.connect(\
		func(_oldVal, newVal):
			self.value = newVal)

	blockStat.max_stat_changed.connect(\
		func(_oldVal, newVal):
			%BlockBar.max_value = newVal)

	blockStat.stat_changed.connect(\
		func(_oldVal, newVal):
			%BlockBar.value = newVal)

	self.value = healthStat.value
	self.max_value = healthStat.maxValue
	%BlockBar.value = blockStat.value
	%BlockBar.value = blockStat.value
