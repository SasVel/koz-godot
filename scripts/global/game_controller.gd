extends Node

@onready var main_scn = load("res://main.tscn")

enum Phases {
	ATTACK,
	DEFEND
}
@onready var turn_counter : int = 0
@onready var rooms_completed : int = 0 :
	set(val):
		rooms_completed = val
		on_rooms_completed.emit(val)
@onready var curr_phase = Phases.ATTACK :
	set(val):
		if curr_phase == val: return

		curr_phase = val
		on_changed_phase.emit(val)

@onready var main : Node2D
@onready var player : Player
@onready var curr_room : Room

@onready var event_queue : Array[Callable]
@onready var is_playing_event : bool = false :
	set(val):
		is_playing_event = val
		switch_input(!is_playing_event)
		if !is_playing_event and event_queue.size() <= 0:
			event_queue_empty.emit()

@onready var enemy_actions : Array[Callable]
@onready var player_status_eff_actions : Array[Callable]
@onready var enemy_status_eff_actions : Array[Callable]

@onready var inputBlocker : Control
@onready var popupsContainer : Control

@onready var player_name : String = "Sasser"
@onready var default_class : Const.PlayerClasses = Const.PlayerClasses.KNIGHT

@onready var is_input : bool = true
@onready var is_object_dragged : bool = false

signal on_start_turn()
signal on_end_turn()
signal on_changed_phase(val : Phases)
signal on_rooms_completed(val : int)
signal event_queue_empty

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(_delta: float) -> void:
	if event_queue.size() > 0 and !is_playing_event:
		await pop_play_event()

func pop_play_event():
	is_playing_event = true
	var event = event_queue.pop_back()
	await event.call()
	is_playing_event = false

func add_event(event : Callable):
	event_queue.push_front(event)

func add_events(event_arr : Array[Callable]):
	if event_queue.size() <= 0:
		event_queue.append_array(event_arr)
		return
	var queue_copy = event_queue.duplicate()
	event_queue = event_arr
	event_queue.append_array(queue_copy)

func init_references():
	main = get_tree().get_root().get_node("Main")
	player = main.get_node("Player")
	Obj.connect_signals({ player.stats.Health.no_stat_val: show_game_over_screen })
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
	curr_phase = Phases.DEFEND
	set_room()

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
	add_events(player_status_eff_actions)
	await event_queue_empty

func play_enemy_anim_stack():
	add_events(enemy_status_eff_actions)
	add_events(enemy_actions)
	await event_queue_empty

func swap_phase():
	curr_phase = Phases.ATTACK if curr_phase == Phases.DEFEND else Phases.DEFEND

func set_room():
	if curr_room != null:
		await curr_room.switch_transition(false)
		curr_room.queue_free()

	var room = ObjManager.get_rand_room()
	main.add_child.call_deferred(room)
	curr_room = room

	room.completed.connect(next_room)
	await room.ready
	await room.switch_transition(true)
	start_turn()

func next_room():
	turn_counter = 0
	rooms_completed += 1
	set_room()

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

func switch_input(isOn : bool):
	is_input = isOn
	inputBlocker.visible = !isOn

func show_game_over_screen():
	var screen = UI.get_popup_inst(UI.Popups.GAME_OVER)
	popupsContainer.add_child(screen)
