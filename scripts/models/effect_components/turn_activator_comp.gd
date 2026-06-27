extends ComponentsData
class_name TurnActivatorComp

@onready var isOn : bool = false

func activate():
	if isOn and Game.turn_counter > 1:
		super()
	else:
		isOn = true
		Obj.connect_signals({ Game.on_start_turn_layer_2: activate })

func deactivate():
	isOn = false
	super()

func generate_desc() -> String:
	return "At the start of each turn, %s" % super()
