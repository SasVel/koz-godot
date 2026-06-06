extends Node

enum Phases {
	ATTACK,
	DEFEND
}
@onready var turn_counter : int = 1 : 
	set(val):
		on_start_turn.emit()
		turn_counter = val
		on_end_turn.emit()

@onready var curr_phase = Phases.ATTACK :
	set(val):
		if curr_phase == val: return

		curr_phase = val
		on_changed_phase.emit(val)

		match curr_phase:
			Phases.ATTACK:
				set_attack_phase()
			Phases.DEFEND:
				set_defend_phase()

@onready var player : Player = get_tree().get_root().get_node("Main/Player")
@onready var enemiesFolder = get_tree().get_root().get_node("Main/Enemies")

signal on_start_turn(val)
signal on_end_turn(val)
signal on_changed_phase(val)

func _ready() -> void:
	await player.ready
	start_game()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("end_turn"):
		end_turn()

func start_game():
	turn_counter = 1
	curr_phase = Phases.ATTACK
	set_attack_phase()

func end_turn():
	turn_counter += 1
	swap_phase()

func swap_phase():
	curr_phase = Phases.ATTACK if curr_phase == Phases.DEFEND else Phases.DEFEND

func set_attack_phase():
	player.stats.Block.value = 0
	
	player.stats.Tempo.maxValue += 1
	player.stats.Tempo.value += 1

func set_defend_phase():
	player.stats.Tempo.maxValue -= 1
	player.stats.Tempo.value -= 1

func get_enemies() -> Array:
	return enemiesFolder.get_children()
