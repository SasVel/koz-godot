extends EffectComponent
class_name ChangePhaseComp

@export var phase : Game.Phases

func activate():
	Game.curr_phase = phase

func generate_desc() -> String:
	return "Change phase to %s." % Game.Phases.keys()[phase]
