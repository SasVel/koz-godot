extends Node

enum Phases {
	ATTACK,
	DEFEND
}
@onready var turn_counter : int = 1
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

@onready var enemy_actions : Array[Callable]

signal on_start_turn()
signal on_end_turn()
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

func start_turn():
	swap_phase()
	turn_counter += 1
	on_start_turn.emit()

func end_turn():
	await play_enemy_anim_stack()
	on_end_turn.emit()
	start_turn()

func play_enemy_anim_stack():
	await get_tree().create_timer(0.2).timeout
	for action in enemy_actions:
		await action.call()

func swap_phase():
	curr_phase = Phases.ATTACK if curr_phase == Phases.DEFEND else Phases.DEFEND

func set_attack_phase():
	apply_attack_phase_modifiers(player)
	for enemy in get_enemies():
		apply_defend_phase_modifiers(enemy)

func set_defend_phase():
	apply_defend_phase_modifiers(player)
	for enemy in get_enemies():
		apply_attack_phase_modifiers(enemy)

func apply_attack_phase_modifiers(entity : Entity):
	entity.stats.Block.value = 0
	
	entity.stats.Tempo.maxValue += 1
	entity.stats.Tempo.value += 1

func apply_defend_phase_modifiers(entity : Entity):
	entity.stats.Tempo.maxValue -= 1
	entity.stats.Tempo.value -= 1

func get_enemies() -> Array:
	var enemies : Array[Enemy]
	for pos in enemyPositions:
		if pos.get_child_count() <= 0: continue
		enemies.append(pos.get_child(0))
	return enemies

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
