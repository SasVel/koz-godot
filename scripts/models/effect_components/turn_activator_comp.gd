extends ComponentsData
class_name TurnActivatorComp

@onready var isOn : bool = false
@export var turns_to_activate : int = 1
var turn_iterator : int = 0

func activate():
	if isOn and Game.turn_counter > 1:
		turn_iterator += 1
		if turn_iterator == turns_to_activate:
			for component in %Components.get_children():
				await UIHelper.tween_eff_trails(source.global_position, component)
				component.activate()
			activated.emit()
			turn_iterator = 0
	else:
		isOn = true
		Obj.connect_signals({ Game.on_start_turn_layer_2: activate })

func deactivate():
	isOn = false
	super()

func generate_desc() -> String:
	if turns_to_activate == 1:
		return "At the start of %s turn, %s" % ["each", super()]
	else:
		return "At the start of %s turns, %s" % ["every " + str(turns_to_activate), super()]
