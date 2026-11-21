extends GutTest

## Tests for scripts/global/game_controller.gd.
##
## Game is an autoload, so tests use the real singleton and isolate it with a
## fake Main scene, fake rooms in ObjManager.rooms_dict, and a no-op
## SceneSwitcher script. See tests/globals/helpers/state.gd.

const FAKE_MAIN := preload("res://tests/globals/stubs/fake_main.tscn")
const FAKE_BATTLE_ROOM := preload("res://tests/globals/stubs/fake_battle_room.tscn")
const FAKE_QUEST_ROOM := preload("res://tests/globals/stubs/fake_quest_room.tscn")
const FAKE_END_ROOM := preload("res://tests/globals/stubs/fake_end_room.tscn")
const SCENE_SWITCHER_STUB := preload("res://tests/globals/stubs/scene_switcher_stub.gd")

const STATE := preload("res://tests/globals/helpers/state.gd")

var _main: Node2D
var _timer
var _orig_rooms: Dictionary[Const.RoomTypes, Array]
var _orig_scene_switcher_script: Script


func before_each() -> void:
	STATE.reset_game()

	_orig_rooms = ObjManager.rooms_dict
	ObjManager.rooms_dict = STATE.fake_rooms()

	_orig_scene_switcher_script = SceneSwitcher.get_script()
	SceneSwitcher.set_script(SCENE_SWITCHER_STUB)

	_main = FAKE_MAIN.instantiate()
	get_tree().root.add_child(_main)
	assert_eq(_main.name, "Main", "The fake Main node must be named Main")
	STATE.bind_main(_main)
	_timer = Game.end_turn_timer


func after_each() -> void:
	get_tree().paused = false
	Game.set_physics_process(false)
	Game.event_queue.clear()

	if Game.end_turn_timer != null and is_instance_valid(Game.end_turn_timer):
		Game.is_playing_event = false

	STATE.unbind_main()
	Game.reset_run_state()
	Game.is_gui_input = true
	Game.time_between_events = 0.3

	if is_instance_valid(_main):
		_main.free()
	_main = null
	_timer = null

	ObjManager.rooms_dict = _orig_rooms
	if _orig_scene_switcher_script != null:
		SceneSwitcher.set_script(_orig_scene_switcher_script)

	Game.set_physics_process(true)


#region Helpers
func _noop_a() -> void:
	pass


func _noop_b() -> void:
	pass


func _noop_c() -> void:
	pass


func _spawn_room(scene: PackedScene) -> Room:
	var room: Room = scene.instantiate()
	_main.add_child(room)
	return room


func _end_turn_event() -> InputEventAction:
	var event := InputEventAction.new()
	event.action = "end_turn"
	event.pressed = true
	return event


func _is_idle() -> bool:
	return not Game.is_playing_event and Game.event_queue.is_empty()


func _is_combat_turn_ready() -> bool:
	return Game.curr_room != null and Game.turn_counter == 1 and _is_idle()


func _is_next_room_ready() -> bool:
	return Game.rooms_completed == 1 and Game.turn_counter == 1 and _is_idle()


func _is_turn_ready() -> bool:
	return Game.turn_counter == 1 and _is_idle()


func _wait_idle(max_time: float = 1.0) -> void:
	await wait_until(_is_idle, max_time)


func _seed_for_quest() -> bool:
	for s in range(100):
		seed(s)
		if randf_range(0.0, 1.0) <= 0.3:
			seed(s)
			return true
	return false
#endregion


#region Lifecycle / initialization
func test_init_sets_process_mode_always() -> void:
	assert_eq(Game.process_mode, Node.PROCESS_MODE_ALWAYS)


func test_init_references_caches_main_nodes() -> void:
	Game.main = null
	Game.cards_layer = null
	Game.player = null
	Game.end_turn_timer = null

	Game.init_references()

	assert_eq(Game.main, _main)
	assert_eq(Game.cards_layer, _main.get_node("%CardsLayer"))
	assert_eq(Game.player, _main.get_node("Player"))
	assert_eq(Game.end_turn_timer, _main.get_node("EndTurnTimer"))


func test_init_unpauses_and_starts_game() -> void:
	get_tree().paused = true
	Game.set_physics_process(true)

	Game.init()

	assert_false(get_tree().paused)
	assert_true(Game.in_game)
	assert_true(Game.is_gui_input)
	assert_eq(Game.main, _main)

	await wait_until(_is_combat_turn_ready, 1.0)

	assert_true(Game.curr_room != null)
	assert_eq(Game.curr_room.type, Const.RoomTypes.Battle)
	# set_room() primes DEFEND, then start_turn() swaps it to ATTACK.
	assert_eq(Game.curr_phase, Game.Phases.ATTACK)


func test_reset_run_state_clears_all_state() -> void:
	var room := _spawn_room(FAKE_BATTLE_ROOM)
	Game.curr_room = room
	Game.turn_counter = 4
	Game.rooms_completed = 3
	Game.curr_phase = Game.Phases.DEFEND
	Game.event_queue.append(func(): pass)
	Game.enemy_actions.append(func(): pass)
	Game.player_status_eff_actions.append(func(): pass)
	Game.enemy_status_eff_actions.append(func(): pass)
	Game.is_playing_event = true
	Game.is_object_dragged = true
	ObjManager.objPickedUp = true
	Game.in_game = true

	watch_signals(Game)
	Game.reset_run_state()

	assert_eq(Game.event_queue.size(), 0)
	assert_eq(Game.enemy_actions.size(), 0)
	assert_eq(Game.player_status_eff_actions.size(), 0)
	assert_eq(Game.enemy_status_eff_actions.size(), 0)
	assert_eq(Game.turn_counter, 0)
	assert_eq(Game.rooms_completed, 0)
	assert_eq(Game.curr_phase, Game.Phases.ATTACK)
	assert_false(Game.is_playing_event)
	assert_false(Game.is_object_dragged)
	assert_false(ObjManager.objPickedUp)
	assert_false(Game.in_game)
	assert_true(Game.curr_room == null)

	assert_signal_emitted_with_parameters(Game, "on_rooms_completed", [0])
	assert_signal_emitted_with_parameters(Game, "on_changed_phase", [Game.Phases.ATTACK])
	assert_signal_emitted_with_parameters(Game, "on_is_playing_event", [false])
	assert_signal_emitted(Game, "event_queue_empty")


func test_restart_unpauses_and_resets_state() -> void:
	get_tree().paused = true
	Game.in_game = true
	Game.turn_counter = 5
	Game.rooms_completed = 2
	Game.curr_phase = Game.Phases.DEFEND
	Game.event_queue.append(func(): pass)
	Game.is_object_dragged = true
	ObjManager.objPickedUp = true

	Game.restart()

	assert_false(get_tree().paused)
	assert_false(Game.in_game)
	assert_eq(Game.turn_counter, 0)
	assert_eq(Game.rooms_completed, 0)
	assert_eq(Game.curr_phase, Game.Phases.ATTACK)
	assert_eq(Game.event_queue.size(), 0)
	assert_false(Game.is_object_dragged)
	assert_false(ObjManager.objPickedUp)
#endregion


#region Event queue
func test_add_event_pushes_front() -> void:
	var first := Callable(self, "_noop_a")
	var second := Callable(self, "_noop_b")

	Game.add_event(first)
	Game.add_event(second)

	assert_eq(Game.event_queue.size(), 2)
	assert_eq(Game.event_queue[0], second)
	assert_eq(Game.event_queue[1], first)


func test_add_event_unique_skips_same_object() -> void:
	var first := Callable(self, "_noop_a")
	var second := Callable(self, "_noop_b")

	Game.add_event(first)
	Game.add_event(second)
	Game.add_event(first, true)

	assert_eq(Game.event_queue.size(), 2)

	Game.add_event(Callable(_main, "queue_free"), true)

	assert_eq(Game.event_queue.size(), 3)


func test_add_events_appends_when_empty() -> void:
	var events: Array[Callable] = [
		Callable(self, "_noop_a"),
		Callable(self, "_noop_b"),
	]

	Game.add_events(events)

	assert_eq(Game.event_queue.size(), 2)
	assert_eq(Game.event_queue[0], events[0])
	assert_eq(Game.event_queue[1], events[1])


func test_add_events_prepends_batch_when_nonempty() -> void:
	var existing := Callable(self, "_noop_a")
	var batch: Array[Callable] = [
		Callable(self, "_noop_b"),
		Callable(self, "_noop_c"),
	]

	Game.add_event(existing)
	Game.add_events(batch)

	assert_eq(Game.event_queue.size(), 3)
	assert_eq(Game.event_queue[0], batch[0])
	assert_eq(Game.event_queue[1], batch[1])
	assert_eq(Game.event_queue[2], existing)


func test_pop_play_event_calls_and_removes() -> void:
	var calls: Array[String] = []
	Game.add_event(func(): calls.append("a"))
	Game.add_event(func(): calls.append("b"))

	await Game.pop_play_event()

	assert_eq(calls, ["a"])
	assert_eq(Game.event_queue.size(), 1)

	await Game.pop_play_event()

	assert_eq(calls, ["a", "b"])
	assert_eq(Game.event_queue.size(), 0)


func test_pop_play_event_skips_freed_object() -> void:
	var object := Node.new()
	var event := Callable(object, "queue_free")
	object.free()
	Game.event_queue.append(event)

	await Game.pop_play_event()

	assert_eq(Game.event_queue.size(), 0)


func test_physics_process_drains_queue_in_order() -> void:
	var calls: Array[String] = []
	Game.add_event(func(): calls.append("a"))
	Game.add_event(func(): calls.append("b"))
	Game.time_between_events = 0.0
	watch_signals(Game)

	Game.set_physics_process(true)
	await wait_for_signal(Game.event_queue_empty, 1.0)

	assert_eq(calls, ["a", "b"])
	assert_eq(Game.event_queue.size(), 0)
	assert_false(Game.is_playing_event)
	assert_signal_emit_count(Game, "on_is_playing_event", 2)
	assert_eq(get_signal_parameters(Game, "on_is_playing_event", 0), [true])
	assert_eq(get_signal_parameters(Game, "on_is_playing_event", 1), [false])


func test_play_player_eff_stack_runs_actions() -> void:
	var calls: Array[String] = []
	Game.player_status_eff_actions.append(func(): calls.append("player"))
	Game.set_physics_process(true)

	await Game.play_player_eff_stack()

	assert_eq(calls, ["player"])
	assert_eq(Game.event_queue.size(), 0)


func test_play_enemy_anim_stack_runs_status_then_actions() -> void:
	var calls: Array[String] = []
	Game.enemy_status_eff_actions.append(func(): calls.append("status"))
	Game.enemy_actions.append(func(): calls.append("action"))
	Game.set_physics_process(true)

	await Game.play_enemy_anim_stack()

	assert_eq(calls, ["status", "action"])
	assert_eq(Game.event_queue.size(), 0)
#endregion


#region Game flow
func test_swap_phase_toggles_and_emits() -> void:
	watch_signals(Game)
	assert_eq(Game.curr_phase, Game.Phases.ATTACK)

	Game.swap_phase()
	assert_eq(Game.curr_phase, Game.Phases.DEFEND)
	assert_signal_emitted_with_parameters(Game, "on_changed_phase", [Game.Phases.DEFEND])

	Game.swap_phase()
	assert_eq(Game.curr_phase, Game.Phases.ATTACK)
	assert_eq(get_signal_parameters(Game, "on_changed_phase", 1), [Game.Phases.ATTACK])


func test_on_start_turn_emit_first_turn() -> void:
	Game.turn_counter = 1
	watch_signals(Game)

	Game.on_start_turn_emit()

	assert_signal_emitted(Game, "on_start_first_turn")
	assert_signal_emitted(Game, "on_start_turn_layer_1")
	assert_signal_emitted(Game, "on_start_turn_layer_2")


func test_on_start_turn_emit_later_turn() -> void:
	Game.turn_counter = 2
	watch_signals(Game)

	Game.on_start_turn_emit()

	assert_signal_not_emitted(Game, "on_start_first_turn")
	assert_signal_emitted(Game, "on_start_turn_layer_1")
	assert_signal_emitted(Game, "on_start_turn_layer_2")


func test_start_turn_swaps_phase_increments_and_emits() -> void:
	Game.set_physics_process(true)
	watch_signals(Game)

	await Game.start_turn()

	assert_eq(Game.curr_phase, Game.Phases.DEFEND)
	assert_eq(Game.turn_counter, 1)
	assert_signal_emitted(Game, "on_start_first_turn")
	assert_signal_emitted(Game, "on_start_turn_layer_1")
	assert_signal_emitted(Game, "on_start_turn_layer_2")


func test_start_turn_second_turn_does_not_emit_first_turn() -> void:
	Game.turn_counter = 1
	Game.set_physics_process(true)
	watch_signals(Game)

	await Game.start_turn()

	assert_eq(Game.turn_counter, 2)
	assert_signal_not_emitted(Game, "on_start_first_turn")
	assert_signal_emitted(Game, "on_start_turn_layer_1")
	assert_signal_emitted(Game, "on_start_turn_layer_2")


func test_end_turn_plays_enemy_actions_and_starts_next_turn() -> void:
	var calls: Array[String] = []
	Game.enemy_actions.append(func(): calls.append("enemy"))
	Game.set_physics_process(true)
	watch_signals(Game)

	await Game.end_turn()
	await _wait_idle()

	assert_eq(calls, ["enemy"])
	assert_signal_emitted(Game, "on_end_player_turn")
	assert_signal_emitted(Game, "on_end_turn")
	assert_eq(Game.curr_phase, Game.Phases.DEFEND)
	assert_eq(Game.turn_counter, 1)
	assert_signal_emitted(Game, "on_start_turn_layer_1")
	assert_signal_emitted(Game, "on_start_turn_layer_2")


func test_end_turn_refreshes_running_timer() -> void:
	_timer.start(10.0)
	await get_tree().create_timer(0.1).timeout
	var time_before: float = _timer.time_left
	Game.enemy_actions.append(func(): pass)
	Game.set_physics_process(true)

	await Game.end_turn()
	await _wait_idle()

	assert_false(_timer.is_stopped())
	assert_true(_timer.time_left > time_before, "A running timer should be restarted")
#endregion


#region Rooms
func test_start_game_sets_in_game_and_loads_room() -> void:
	Game.set_physics_process(true)

	Game.start_game()

	assert_true(Game.in_game)
	await wait_until(_is_combat_turn_ready, 1.0)
	assert_true(Game.curr_room != null)
	assert_eq(Game.curr_room.type, Const.RoomTypes.Battle)
	assert_eq(Game.curr_phase, Game.Phases.ATTACK)


func test_set_room_first_room_is_battle() -> void:
	Game.set_physics_process(true)
	watch_signals(Game)

	await Game.set_room()

	assert_true(Game.curr_room != null)
	assert_eq(Game.curr_room.type, Const.RoomTypes.Battle)
	assert_eq(Game.curr_room.get_parent(), _main)
	assert_signal_emitted(Game, "on_new_room")
	assert_eq(Game.curr_phase, Game.Phases.ATTACK)
	assert_eq(Game.turn_counter, 1)


func test_set_room_uses_end_game_after_ten_rooms() -> void:
	var rooms_for_end_room: int = Game.rooms_for_end_room
	ObjManager.rooms_dict[Const.RoomTypes.EndGame] = [FAKE_END_ROOM]
	Game.rooms_completed = rooms_for_end_room
	Game.set_physics_process(true)

	await Game.set_room()

	assert_true(Game.curr_room != null)
	assert_eq(Game.curr_room.type, Const.RoomTypes.EndGame)
	assert_false(Game.curr_room.is_combat)
	assert_eq(Game.turn_counter, 0)


func test_set_room_uses_quest_room_for_late_roll() -> void:
	var rooms_for_quest_room: int = Game.rooms_for_quest_room
	ObjManager.rooms_dict[Const.RoomTypes.Quest] = [FAKE_QUEST_ROOM]
	Game.rooms_completed = rooms_for_quest_room + 1
	assert_true(_seed_for_quest(), "Could not find a seed that rolls a quest room")
	Game.set_physics_process(true)

	await Game.set_room()

	assert_true(Game.curr_room != null)
	assert_eq(Game.curr_room.type, Const.RoomTypes.Quest)
	assert_false(Game.curr_room.is_combat)


func test_set_room_combat_starts_first_turn() -> void:
	Game.set_physics_process(true)
	watch_signals(Game)

	await Game.set_room()

	assert_true(Game.curr_room != null)
	assert_eq(Game.curr_room.type, Const.RoomTypes.Battle)
	assert_true(Game.curr_room.is_combat)
	assert_eq(Game.curr_phase, Game.Phases.ATTACK)
	assert_eq(Game.turn_counter, 1)
	assert_signal_emitted(Game, "on_start_turn_layer_1")
	assert_signal_emitted(Game, "on_start_turn_layer_2")


func test_set_room_replaces_existing_room() -> void:
	var old_room := _spawn_room(FAKE_BATTLE_ROOM)
	Game.curr_room = old_room
	Game.set_physics_process(true)

	await Game.set_room()

	assert_true(Game.curr_room != null)
	assert_true(Game.curr_room != old_room)
	assert_eq(Game.curr_room.type, Const.RoomTypes.Battle)
	assert_eq(Game.curr_room.get_parent(), _main)
	assert_true(not is_instance_valid(old_room) or old_room.is_queued_for_deletion())


func test_next_room_increments_and_resets_turn() -> void:
	var old_room := _spawn_room(FAKE_BATTLE_ROOM)
	Game.curr_room = old_room
	Game.turn_counter = 4
	Game.set_physics_process(true)

	Game.next_room()

	await wait_until(_is_next_room_ready, 1.0)

	assert_eq(Game.rooms_completed, 1)
	assert_eq(Game.turn_counter, 1)
	assert_true(Game.curr_room != null)
	assert_eq(Game.curr_room.type, Const.RoomTypes.Battle)
	assert_eq(Game.curr_phase, Game.Phases.ATTACK)
#endregion


#region Input / misc
func test_unhandled_input_ignores_when_gui_input_disabled() -> void:
	Game.is_gui_input = false
	watch_signals(Game)

	Game._unhandled_input(_end_turn_event())

	assert_signal_not_emitted(Game, "on_end_player_turn")


func test_unhandled_input_ignores_when_paused() -> void:
	get_tree().paused = true
	Game.is_gui_input = true
	watch_signals(Game)

	Game._unhandled_input(_end_turn_event())

	assert_signal_not_emitted(Game, "on_end_player_turn")
	get_tree().paused = false


func test_unhandled_input_end_turn_drives_full_turn() -> void:
	Game.enemy_actions.append(func(): pass)
	Game.set_physics_process(true)
	Game.is_gui_input = true
	get_tree().paused = false
	watch_signals(Game)

	Game._unhandled_input(_end_turn_event())

	await wait_until(_is_turn_ready, 1.0)

	assert_signal_emitted(Game, "on_end_player_turn")
	assert_signal_emitted(Game, "on_end_turn")
	assert_eq(Game.curr_phase, Game.Phases.DEFEND)
	assert_eq(Game.turn_counter, 1)


func test_add_and_remove_status_eff_actions() -> void:
	var action := Callable(self, "_noop_a")

	Game.add_status_eff_action(action, true)
	Game.add_status_eff_action(action, false)

	assert_eq(Game.player_status_eff_actions.size(), 1)
	assert_eq(Game.player_status_eff_actions[0], action)
	assert_eq(Game.enemy_status_eff_actions.size(), 1)
	assert_eq(Game.enemy_status_eff_actions[0], action)

	Game.remove_status_eff_action(action, true)
	Game.remove_status_eff_action(action, false)

	assert_eq(Game.player_status_eff_actions.size(), 0)
	assert_eq(Game.enemy_status_eff_actions.size(), 0)


func test_switch_input_toggles_gui_input() -> void:
	Game.switch_input(false)

	assert_false(Game.is_gui_input)
	assert_false(_main.is_processing_input())

	Game.switch_input(true)

	assert_true(Game.is_gui_input)
	assert_true(_main.is_processing_input())


func test_start_end_turn_timer_queues_bound_call() -> void:
	Game.start_end_turn_timer(5.0)

	assert_eq(Game.event_queue.size(), 1)
	assert_eq(Game.event_queue[0].get_bound_arguments(), [5.0])

	await Game.pop_play_event()

	assert_eq(_timer.timer_start_calls, [5.0])


func test_refresh_end_turn_timer_stopped_is_noop() -> void:
	assert_true(_timer.is_stopped())

	Game.refresh_end_turn_timer()

	assert_true(_timer.is_stopped())


func test_refresh_end_turn_timer_running_restarts() -> void:
	_timer.start(10.0)
	await get_tree().create_timer(0.1).timeout
	var time_before: float = _timer.time_left

	Game.refresh_end_turn_timer()

	assert_false(_timer.is_stopped())
	assert_true(_timer.time_left > time_before, "Refresh should restart the timer")


func test_stop_end_turn_timer_calls_stop() -> void:
	_timer.start(10.0)
	assert_false(_timer.is_stopped())

	Game.stop_end_turn_timer()

	assert_true(_timer.is_stopped())
#endregion
