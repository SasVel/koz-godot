extends Resource
class_name DrawController

enum DrawMode { Random, Sequential }

@export var draw_mode : DrawMode = DrawMode.Random

func pick(actions : Array[CardData], allowed_suits : Array = [], \
		excluded : Array = []) -> CardData:
	var candidates : Array[CardData] = []
	for action in actions:
		if action == null or excluded.has(action): continue
		if allowed_suits.size() > 0 and not allowed_suits.has(action.suit): continue
		candidates.append(action)
	if candidates.is_empty(): return null
	if draw_mode == DrawMode.Sequential:
		return candidates[0]
	return candidates.pick_random()

func pop(actions : Array[CardData], allowed_suits : Array = [], \
		excluded : Array = []) -> CardData:
	var action := pick(actions, allowed_suits, excluded)
	if action != null:
		actions.erase(action)
	return action
