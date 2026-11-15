extends EffectComponent
class_name SuitChangeComponent

enum Mode {
	Random,
	Shifting,
	Exact
}
@export var mode : Mode
@export var suit_type : Const.SuitTypes

func _ready() -> void:
	self.isOffensive = false

func activate():
	match mode:
		Mode.Random:
			Game.curr_room.koz_suit = \
				randi_range(0, Const.SuitTypes.size() - 1) as Const.SuitTypes
		Mode.Shifting:
			var new_suit_idx = int(Game.curr_room.koz_suit) + 1
			if new_suit_idx > Const.SuitTypes.size() - 1:
				new_suit_idx = 0
			Game.curr_room.koz_suit = new_suit_idx as Const.SuitTypes
		Mode.Exact:
			Game.curr_room.koz_suit = suit_type

func generate_desc() -> String:
	match mode:
		Mode.Random:
			return "Set Koz suit to a random suit."
		Mode.Shifting:
			return "Shift Koz suit to the next in line."
		Mode.Exact:
			return "Set Koz suit to %s." % Const.SuitTypes.keys()[suit_type]
	return ""
