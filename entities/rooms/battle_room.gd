extends Room
class_name BattleRoom

@onready var enemiesFolder : Node = %Enemies
@onready var enemyPositions : Array

func _ready() -> void:
	super()
	enemyPositions = [
		enemiesFolder.get_child(0),
		enemiesFolder.get_child(1),
		enemiesFolder.get_child(2),
	]
	add_enemy(ObjManager.get_enemy_obj(ObjManager.enemies_dict[Const.Enemies.SKELLY].instantiate()))

func get_enemies() -> Array:
	var enemies : Array[Enemy]
	for pos in enemyPositions:
		if pos.get_child_count() <= 0: continue
		enemies.append(pos.get_child(0))
	return enemies

func add_enemy(enemy_obj : Enemy):
	for pos in enemyPositions:
		if pos.get_children().size() > 0:
			continue
		pos.add_child(enemy_obj)
		enemy_obj.tree_exited.connect(try_complete_battle)
		break

func try_complete_battle():
	if check_enemies_dead():
		var loot_popup = UI.get_popup_inst(UI.Popups.LOOT)
		Game.popupsContainer.add_child(loot_popup)
		await loot_popup.finished
		Game.next_room()


func check_enemies_dead():
	return get_enemies()\
		.filter(func(x): return !x.is_queued_for_deletion())\
		.size() <= 0

func clear_enemies():
	for pos in enemyPositions:
		if pos.get_child_count() <= 0: continue
		pos.get_child(0).queue_free()
