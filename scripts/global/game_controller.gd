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
@onready var enemyPositions = [
	enemiesFolder.get_child(0),
	enemiesFolder.get_child(1),
	enemiesFolder.get_child(2),
]

signal on_start_turn(val)
signal on_end_turn(val)
signal on_changed_phase(val : Phases)

func _ready() -> void:
	await player.ready
	start_game()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("end_turn"):
		end_turn()

func start_game():
	curr_phase = Phases.ATTACK
	set_attack_phase()
	set_room()
	turn_counter = 1

func end_turn():
	swap_phase()
	turn_counter += 1

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

func set_room(type : Const.RoomTypes = Const.RoomTypes.Random):
	clear_enemies()
	add_enemy(ObjManager.get_rand_enemy_obj())

func add_enemy(enemy_obj : Enemy):
	for pos in enemyPositions:
		if pos.get_children().size() > 0:
			continue
		pos.add_child(enemy_obj)
		break

func clear_enemies():
	for pos in enemyPositions:
		if pos.get_child_count() <= 0: continue
		pos.get_child(0).queue_free()
