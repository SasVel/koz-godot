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
	get():
		var val = tempoCost
		if source != null and \
		(type == Const.CardTypes.WEAPON or \
		type == Const.CardTypes.SHIELD):
			for eff in source.get_effects(Const.StatusEffects.CONSTRICT):
				val += eff.stacks
		return val

@onready var isOn = true :
	set(val):
		if isOn == val: return
		isOn = val
		changed_state.emit(val)

@onready var card_object : CardObj

signal changed_state(val)
signal tempo_changed(oldVal : int, val : int)
signal update_status()

func config_source(source_ : Entity):
	super(source_)
	source.stats.Tempo.stat_changed.connect(func(_x, _y): check_state())
	source.status_effects_changed.connect(update_status_state)

func activate(deduct_tempo : bool = true):
	if deduct_tempo:
		source.stats.Tempo.value -= self.tempoCost
	super()

func get_generic_value():
	return %Components.get_child(0).value

func get_components() -> Array[EffectComponent]:
	var components = %Components.get_children()
	return components.map(func(x): return x as EffectComponent)

func check_state():
	isOn = can_activate()

func update_status_state(effects : Array[StatusEffData]):
	if effects.any(func(x): return x.type == Const.StatusEffects.CONSTRICT):
		check_state()
		tempo_changed.emit(null, tempoCost)
	update_status.emit()

func can_activate():
	return source.stats.Tempo.value >= self.tempoCost
