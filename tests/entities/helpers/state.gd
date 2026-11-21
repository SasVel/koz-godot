extends RefCounted


static func reset() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		tree.paused = false

	# Prevent Game.init_references()/switch_input() from touching stale scene nodes.
	Game.main = null
	Game.set_physics_process(false) # keep the event queue deterministic
	Game.reset_run_state()          # clears queues, phase, flags, objPickedUp
	Game.player = null
	UI.is_paused = false


static func cleanup_entity(e: Entity) -> void:
	if e == null:
		return

	for sig in [Game.on_start_turn_layer_2, Game.on_changed_phase, Game.on_new_room]:
		for conn in sig.get_connections():
			if conn.callable.get_object() == e:
				sig.disconnect(conn.callable)

	# Production connects lambdas from the stat resources back to the entity.
	# Those connections create a reference cycle that keeps the duplicated
	# StatBlock/Stat resources alive, so break them before freeing the entity.
	if e.stats != null:
		for sig in [
			e.stats.Health.stat_changed,
			e.stats.Health.max_stat_changed,
			e.stats.Health.no_stat_val,
			e.stats.Block.stat_changed,
			e.stats.Block.max_stat_changed,
			e.stats.Tempo.stat_changed,
			e.stats.Tempo.max_stat_changed,
			e.status_effects_changed,
		]:
			for conn in sig.get_connections():
				sig.disconnect(conn.callable)


static func restore() -> void:
	Game.reset_run_state()
	Game.set_physics_process(true)
