extends Node

@onready var main_scn = load("res://main.tscn")

enum Phases {
	ATTACK,
	DEFEND
}
@onready var turn_counter : int = 1
@onready var rooms_completed : int = 0 :
	set(val):
		rooms_completed = val
		on_rooms_completed.emit(val)
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

@onready var main : Node2D
@onready var player : Player
@onready var enemiesFolder : Node
@onready var enemyPositions : Array
@onready var enemy_actions : Array[Callable]
@onready var player_status_eff_actions : Array[Callable]
@onready var enemy_status_eff_actions : Array[Callable]
@onready var is_input : bool = true
@onready var inputBlocker : Control
@onready var popupsContainer : Control

signal on_start_turn()
signal on_end_turn()
signal on_changed_phase(val : Phases)
signal on_rooms_completed(val : int)

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func init_references():
	main = get_tree().get_root().get_node("Main")
	player = main.get_node("Player")
	Obj.connect_signals({ player.stats.Health.no_stat_val: show_game_over_screen })
	enemiesFolder = main.get_node("Enemies")
	enemyPositions = [
		enemiesFolder.get_child(0),
		enemiesFolder.get_child(1),
		enemiesFolder.get_child(2),
	]
	inputBlocker = main.get_node("UI/InputBlocker")
	popupsContainer = main.get_node("UIOverEverything/PopupsContainer")

func init():
	get_tree().paused = false
	init_references()
	start_game()
	switch_input(true)

func restart():
	get_tree().current_scene.queue_free()
	get_tree().change_scene_to_packed(main_scn)
	await get_tree().scene_changed
	init()

func _unhandled_input(event: InputEvent) -> void:
	if !is_input: return

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
	await play_player_eff_stack()

func end_turn():
	await play_enemy_anim_stack()
	on_end_turn.emit()
	start_turn()

func play_player_eff_stack():
	switch_input(false)
	await get_tree().create_timer(0.2).timeout

	for action in player_status_eff_actions:
		await action.call()

	switch_input(true)

func play_enemy_anim_stack():
	switch_input(false)
	await get_tree().create_timer(0.2).timeout

	for action in enemy_status_eff_actions:
		await action.call()
	await get_tree().create_timer(0.2).timeout

	for action in enemy_actions:
		await action.call()
	switch_input(true)

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

func next_room():
	turn_counter = 1
	rooms_completed += 1
	set_room()

func add_enemy(enemy_obj : Enemy):
	for pos in enemyPositions:
		if pos.get_children().size() > 0:
			continue
		pos.add_child(enemy_obj)
		enemy_obj.tree_exited.connect(try_complete_battle)
		break

func add_status_eff_action(action : Callable, is_for_player):
	if is_for_player:
		player_status_eff_actions.append(action)
	else:
		enemy_status_eff_actions.append(action)

func remove_status_eff_action(action : Callable, is_for_player):
	if is_for_player:
		player_status_eff_actions.erase(action)
	else:
		enemy_status_eff_actions.erase(action)

func try_complete_battle():
	if check_battle_completed():
		next_room()

func check_battle_completed():
	return get_enemies()\
		.filter(func(x): return !x.is_queued_for_deletion())\
		.size() <= 0

func clear_enemies():
	for pos in enemyPositions:
		if pos.get_child_count() <= 0: continue
		pos.get_child(0).queue_free()

func switch_input(isOn : bool):
	is_input = isOn
	inputBlocker.visible = !isOn

func show_game_over_screen():
	var screen = UI.get_popup_inst(UI.Popups.GAME_OVER)
	popupsContainer.add_child(screen)
