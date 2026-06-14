extends ComponentsData
class_name CardData

@export var type : Const.CardTypes = Const.CardTypes.ACTION
@export var isGeneric : bool = false

@export var actionType : Const.Actions
@export var weaponType : Const.Weapons
@export var shieldType : Const.Shields

@export var tempoCost : int = 1 :
	set(val):
		tempoCost = val
		tempo_changed.emit(val)

@onready var isOn = true :
	set(val):
		if isOn == val: return
		isOn = val
		changed_state.emit(val)


signal changed_state(val)
signal tempo_changed(val)

func config_source(source_ : Entity):
	super(source_)
	source.stats.Tempo.stat_changed.connect(func(_x, _y): check_state())

func activate():
	source.stats.Tempo.value -= self.tempoCost
	super()

func get_generic_value():
	return %Components.get_child(0).value

func check_state():
	isOn = can_activate()

func can_activate():
	return source.stats.Tempo.value >= self.tempoCost
