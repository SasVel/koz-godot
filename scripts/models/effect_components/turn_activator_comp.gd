extends ComponentsData
class_name TurnActivatorComp

@onready var isOn : bool = false

func _ready() -> void:
	Game.on_start_turn.connect(activate)

func activate():
	if isOn:
		super()
	else:
		isOn = true
		Obj.connect_signals({ Game.on_start_turn: activate })

func deactivate():
	isOn = false
	super()

func generate_desc() -> String:
	return "At the start of each turn, %s" % super()
