extends Node
class_name EntityData

@export var entity_name : String
@export_multiline var desc : String
@export var default_stats : StatBlock

@export var card_deck_types : Array[Const.Actions]
@onready var card_deck : Array[CardData]
@export var card_hand_size : int = 2

signal card_hand_size_changed(val : int)

func config():
	if %Cards.get_child_count() > 0:
		card_deck.assign(%Cards.get_children())
	else:
		card_deck = ObjManager.get_action_datas(card_deck_types)
	return self

func activate():
	for component in %Components.get_children():
		component.activate()

func deactivate():
	for component in %Components.get_children():
		component.deactivate()

func generate_desc() -> String:
	var resArr : Array[String]
	for component in %Components.get_children():
		resArr.append(component.generate_desc())

	return "\n".join(resArr) if resArr.size() > 0 else ""
