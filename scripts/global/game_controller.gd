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

@onready var time_between_events : float = 0.3
@onready var event_queue : Array[Callable]
@onready var is_playing_event : bool = false :
	set(val):
		if is_playing_event == val:
			return

		is_playing_event = val
		on_is_playing_event.emit(is_playing_event)
		end_turn_timer.paused = is_playing_event
		switch_input(!is_playing_event)
		if !is_playing_event and event_queue.size() <= 0:
			event_queue_empty.emit()

@onready var enemy_actions : Array[Callable]
@onready var player_status_eff_actions : Array[Callable]
@onready var enemy_status_eff_actions : Array[Callable]
@onready var end_turn_timer : EndTurnTimer

@onready var ui_over_everything : Control = %UIOverEverything
@onready var popupsContainer : Control = %PopupsContainer
@onready var visualEffectsContainer : Control = %Effects

@onready var player_name : String = "Sasser"
@onready var default_class : Const.PlayerClasses = Const.PlayerClasses.KNIGHT

@onready var in_game : bool = false
@onready var is_gui_input : bool = true :
	set(val):
		get_tree().get_root().gui_disable_input = !val
		is_gui_input = val

@onready var is_object_dragged : bool = false

signal on_start_first_turn
signal on_start_turn_layer_1
signal on_start_turn_layer_2

signal on_end_player_turn
signal on_end_turn
signal on_changed_phase(val : Phases)
signal on_rooms_completed(val : int)
signal on_new_room
signal event_queue_empty
signal on_is_playing_event(val : bool)

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(_delta: float) -> void:
	if event_queue.size() > 0 and !is_playing_event:
		await pop_play_event()
		await get_tree().create_timer(time_between_events).timeout
		if event_queue.size() <= 0:
			is_playing_event = false

func pop_play_event():
	var event = event_queue.pop_back()
	if event.get_object() != null:
		is_playing_event = true
		print(str(event) + ": " + str(event.get_bound_arguments()))
		await event.call()
		is_playing_event = false

func add_event(event : Callable, is_unique : bool = false):
	if is_unique and \
	event_queue.any(func(x): return x.get_object() == event.get_object()):
		return
	event_queue.push_front(event)

func add_events(event_arr : Array[Callable]):
	if event_queue.size() <= 0:
		event_queue.append_array(event_arr)
		return
	var queue_copy = event_queue.duplicate()
	event_queue.clear()
	event_queue.append_array(event_arr)
	event_queue.append_array(queue_copy)

func init_references():
	main = get_tree().get_root().get_node("Main")
	player = main.get_node("Player")
	end_turn_timer = main.get_node("EndTurnTimer")

func init():
	get_tree().paused = false
	init_references()
	start_game()
	switch_input(true)

func restart():
	SceneSwitcher.switch_to_scene(main_scn)
	get_tree().change_scene_to_packed(main_scn)
	await get_tree().scene_changed
	init()

func _unhandled_input(event: InputEvent) -> void:
	if !is_gui_input: return

	if event.is_action_pressed("end_turn"):
		end_turn()

func start_game():
	in_game = true
	set_room()

func start_turn():
	swap_phase()
	turn_counter += 1
	add_event(on_start_turn_emit)
	await play_player_eff_stack()

func on_start_turn_emit():
	if turn_counter == 1:
		on_start_first_turn.emit()
	on_start_turn_layer_1.emit()
	on_start_turn_layer_2.emit()

func end_turn():
	on_end_player_turn.emit()
	await play_enemy_anim_stack()
	on_end_turn.emit()
	refresh_end_turn_timer()
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
		add_event(SceneSwitcher.switch_transition.bind(false))
		await event_queue_empty
		curr_room.queue_free()

	var room : Room
	if turn_counter >= 10:
		room = ObjManager.get_room(Const.RoomTypes.EndGame)
	else:
		if turn_counter > 3 and randf_range(0, 1) <= 0.3:
			room = ObjManager.get_room(Const.RoomTypes.Quest)
		else:
			room = ObjManager.get_room(Const.RoomTypes.Battle)

	main.add_child.call_deferred(room)
	curr_room = room

	room.completed.connect(next_room)
	await room.ready
	on_new_room.emit()
	add_event(SceneSwitcher.switch_transition.bind(true))
	await event_queue_empty

	if curr_room.is_combat:
		curr_phase = Phases.DEFEND
		await start_turn()

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
	is_gui_input = isOn

func start_end_turn_timer(wait_time):
	add_event(end_turn_timer.timer_start.bind(wait_time))

func refresh_end_turn_timer():
	if end_turn_timer.is_stopped():
		return
	end_turn_timer.stop()
	end_turn_timer.start()

func stop_end_turn_timer():
	end_turn_timer.stop()
