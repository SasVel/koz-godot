extends EffectComponent
class_name TimedRoundComp

func activate():
	Game.start_end_turn_timer(float(process_value(value)))

func deactivate():
	Game.stop_end_turn_timer()

func generate_desc() -> String:
	return "Ends the round after %.f secs." % process_value(value)
