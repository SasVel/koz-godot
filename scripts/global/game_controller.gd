extends Node

@onready var main_scn = load("res://main.tscn")

enum Phases {
	ATTACK,
	DEFEND
}

@onready var turn_counter : int = 0
@onready var rooms_completed : int = 0 :
	set(val):
		if rooms_completed == val: return
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
@onready var cards_layer : CanvasLayer

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
		if main != null:
			main.set_process_input(val)
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

## koz suit variable is held in each room. 
## This signal is here for easy access from other scripts.
@warning_ignore("unused_signal")
signal koz_suit_changed(suit : Const.SuitTypes)

#region Lifecycle
func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(_delta: float) -> void:
	if event_queue.size() > 0 and !is_playing_event:
		is_playing_event = true
		while event_queue.size() > 0:
			await pop_play_event()
			if event_queue.size() > 0:
				await get_tree().create_timer(time_between_events).timeout
		is_playing_event = false

func _unhandled_input(event: InputEvent) -> void:
	if !is_gui_input or get_tree().paused: return

	if event.is_action_pressed("end_turn"):
		end_turn()

# Unpauses the game, caches references, starts the game and enables input.
func init():
	get_tree().paused = false
	init_references()
	reset_run_state()
	start_game()
	switch_input(true)

func reset_run_state():
	event_queue.clear()
	enemy_actions.clear()
	player_status_eff_actions.clear()
	enemy_status_eff_actions.clear()
	curr_room = null
	turn_counter = 0
	rooms_completed = 0
	curr_phase = Phases.ATTACK
	is_playing_event = false
	is_object_dragged = false
	ObjManager.objPickedUp = false
	in_game = false

# Caches main scene nodes used by the controller.
func init_references():
	main = get_tree().get_root().get_node("Main")
	cards_layer = main.get_node("%CardsLayer")
	player = main.get_node("Player")
	end_turn_timer = main.get_node("EndTurnTimer")

# Reloads the main scene and initialises the game again.
func restart():
	get_tree().paused = false
	SceneSwitcher.switch_to_scene(main_scn)
	reset_run_state()

#endregion

#region Game Flow
# Flags the game as running and loads the first room.
func start_game():
	in_game = true
	set_room()

# Picks the next room type and swaps it in with a transition.
func set_room():
	if curr_room != null:
		add_event(SceneSwitcher.switch_transition.bind(false))
		await event_queue_empty
		curr_room.queue_free()

	var room : Room
	if rooms_completed >= 10:
		room = ObjManager.get_room(Const.RoomTypes.EndGame)
	else:
		if rooms_completed > 3 and randf_range(0, 1) <= 0.3:
			room = ObjManager.get_room(Const.RoomTypes.Quest)
		else:
			room = ObjManager.get_room(Const.RoomTypes.Battle)

	main.add_child.call_deferred(room)
	curr_room = room

	room.completed.connect(next_room)
	await room.ready
	if rooms_completed > 0:
		add_event(SceneSwitcher.switch_transition.bind(true))
	on_new_room.emit()
	await event_queue_empty

	if curr_room.is_combat:
		curr_phase = Phases.DEFEND
		await start_turn()

# Completes the current room and loads the next one.
func next_room():
	turn_counter = 0
	rooms_completed += 1
	set_room()

# Swaps phase, increments the turn and plays player effects.
func start_turn():
	swap_phase()
	turn_counter += 1
	add_event(on_start_turn_emit)
	await play_player_eff_stack()

# Emits the start-of-turn signals.
func on_start_turn_emit():
	if turn_counter == 1:
		on_start_first_turn.emit()
	on_start_turn_layer_1.emit()
	on_start_turn_layer_2.emit()

# Ends the player turn, plays enemy actions and starts the next turn.
func end_turn():
	on_end_player_turn.emit()
	await play_enemy_anim_stack()
	on_end_turn.emit()
	refresh_end_turn_timer()
	start_turn()

# Toggles between attack and defend phases.
func swap_phase():
	curr_phase = Phases.ATTACK if curr_phase == Phases.DEFEND else Phases.DEFEND

#endregion

#region Event Queue
# Adds one event to the front of the queue, optionally skipping duplicates.
func add_event(event : Callable, is_unique : bool = false):
	if is_unique and \
	event_queue.any(func(x): return x.get_object() == event.get_object()):
		return
	event_queue.push_front(event)

# Inserts a batch of events ahead of the existing queue.
func add_events(event_arr : Array[Callable]):
	if event_queue.size() <= 0:
		event_queue.append_array(event_arr)
		return
	var queue_copy = event_queue.duplicate()
	event_queue.clear()
	event_queue.append_array(event_arr)
	event_queue.append_array(queue_copy)

# Pops and awaits the next valid event.
func pop_play_event() -> void:
	var event = event_queue.pop_back()
	if event.get_object() != null:
		print(str(event) + ": " + str(event.get_bound_arguments()))
		await event.call()

# Queues player status effects and waits for them.
func play_player_eff_stack():
	add_events(player_status_eff_actions)
	await event_queue_empty

# Queues enemy status effects and actions, then waits.
func play_enemy_anim_stack():
	add_events(enemy_status_eff_actions)
	add_events(enemy_actions)
	await event_queue_empty

#endregion

#region Misc
# Registers a status effect callable for the player or enemies.
func add_status_eff_action(action : Callable, is_for_player):
	if is_for_player:
		player_status_eff_actions.append(action)
	else:
		enemy_status_eff_actions.append(action)

# Unregisters a status effect callable.
func remove_status_eff_action(action : Callable, is_for_player):
	if is_for_player:
		player_status_eff_actions.erase(action)
	else:
		enemy_status_eff_actions.erase(action)

# Enables or disables input on the root viewport.
func switch_input(isOn : bool):
	is_gui_input = isOn

# Queues the end-turn timer start.
func start_end_turn_timer(wait_time):
	add_event(end_turn_timer.timer_start.bind(wait_time))

# Restarts the end-turn timer if it is running.
func refresh_end_turn_timer():
	if end_turn_timer.is_stopped():
		return
	end_turn_timer.stop()
	end_turn_timer.start()

# Stops the end-turn timer.
func stop_end_turn_timer():
	end_turn_timer.stop()

#endregion
