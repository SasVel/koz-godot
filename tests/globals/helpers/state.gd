extends RefCounted


const FAKE_BATTLE_ROOM := preload("res://tests/globals/stubs/fake_battle_room.tscn")
const FAKE_QUEST_ROOM := preload("res://tests/globals/stubs/fake_quest_room.tscn")
const FAKE_END_ROOM := preload("res://tests/globals/stubs/fake_end_room.tscn")


static func fake_rooms() -> Dictionary[Const.RoomTypes, Array]:
	var rooms: Dictionary[Const.RoomTypes, Array] = {}
	rooms[Const.RoomTypes.Battle] = [FAKE_BATTLE_ROOM]
	rooms[Const.RoomTypes.Quest] = [FAKE_QUEST_ROOM]
	rooms[Const.RoomTypes.EndGame] = [FAKE_END_ROOM]
	return rooms


static func reset_game() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		tree.paused = false

	Game.set_physics_process(false)
	Game.event_queue.clear()

	# The setter touches end_turn_timer, so clear it while the timer is valid.
	if Game.end_turn_timer != null and is_instance_valid(Game.end_turn_timer):
		Game.is_playing_event = false

	Game.main = null
	Game.cards_layer = null
	Game.player = null
	Game.end_turn_timer = null
	Game.curr_room = null

	Game.reset_run_state()
	Game.is_gui_input = true
	Game.time_between_events = 0.0
	UI.is_paused = false
	ObjManager.objPickedUp = false


static func bind_main(main: Node2D) -> void:
	Game.main = main
	Game.cards_layer = main.get_node("%CardsLayer") as CanvasLayer
	Game.player = main.get_node("Player") as Player
	Game.end_turn_timer = main.get_node("EndTurnTimer") as EndTurnTimer


static func unbind_main() -> void:
	Game.main = null
	Game.cards_layer = null
	Game.player = null
	Game.end_turn_timer = null
	Game.curr_room = null
