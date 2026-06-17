extends EffectComponent
class_name PlayActionsComp

## Value is the count of cards played on activaton.

func activate():
	source.play_rand_actions_hand(value, false, [owner])
	super()

func generate_desc() -> String:
	return "Play %.f random cards from hand." % value
