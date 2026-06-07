extends Node
class_name EntityData

@export var entity_name : String
@export_multiline var desc : String
@export var default_stats : StatBlock
@export var card_deck_types : Array[Const.Actions]
@onready var card_deck : Array[CardData]
@export var card_hand_size : int = 2

func config():
	card_deck = ObjManager.get_action_datas(card_deck_types)
	return self
