extends Resource
class_name Stat

@export var value : float = 10.0 :
	set(val):
		var newVal = 0
		if maxValue == 0.0:
			# No cap, but clamp to 0.0 to prevent negative values
			newVal = clamp(val, 0.0, 0.0)
			stat_changed.emit(value, newVal)
			value = newVal
			return

		# Apply cap when maxValue > 0.0
		newVal = min(val, maxValue)
		# Emit signal and update only if value actually changed
		if value != newVal:
			stat_changed.emit(value, newVal)
			value = newVal
		if newVal <= 0.0:
			no_stat_val.emit()

## No cap is applied if the value is 0.0.
@export var maxValue : float = 100.0 :
	set(val):
		max_stat_changed.emit(maxValue, val)
		maxValue = max(val, 0.0)

signal stat_changed(oldVal : float, newVal : float)
signal max_stat_changed(oldVal : float, newVal : float)
signal no_stat_val

func add(stat : Stat):
	self.value += stat.value
	self.maxValue += stat.maxValue

func sub(stat : Stat):
	self.value -= stat.value
	self.maxValue -= stat.maxValue

func reset():
	if maxValue <= 0.0: return
	value = maxValue
