extends Resource
class_name Stat

@export var value : int = 10 :
	set(val):
		if value == val: return
		var newVal = 0
		var oldVal = value
		if maxValue == 0.0:
			# No cap, but clamp to 0.0 to prevent negative values
			newVal = clamp(val, 0.0, 0.0)
			value = newVal
			stat_changed.emit(oldVal, newVal)
			return

		# Apply cap when maxValue > 0.0
		newVal = min(val, maxValue)
		# Emit signal and update only if value actually changed
		if value != newVal:
			value = newVal
			stat_changed.emit(oldVal, newVal)
		if newVal <= 0.0:
			no_stat_val.emit()

## No cap is applied if the value is 0.0.
@export var maxValue : int = 100 :
	set(val):
		if maxValue == val: return
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
