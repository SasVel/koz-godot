extends Node

enum Phases {
	ATTACK,
	DEFEND
}

@onready var curr_phase = Phases.ATTACK
@onready var player = get_tree().get_root().get_node("Main/Player")
@onready var enemiesFolder = get_tree().get_root().get_node("Main/Enemies")

func _ready() -> void:
	print(player)
	print(enemiesFolder)

func swap_phase():
	curr_phase = Phases.ATTACK if curr_phase == Phases.DEFEND else Phases.DEFEND
