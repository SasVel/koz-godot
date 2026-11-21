extends RefCounted


static func stat_block(health: int = 10, block: int = 0, tempo: int = 3) -> StatBlock:
	var sb := StatBlock.new()
	sb.Health.maxValue = health
	# StatBlock only re-caps Block when Health changes, so set it explicitly.
	sb.Block.maxValue = health
	sb.Block.value = block
	sb.Tempo.maxValue = tempo
	sb.Tempo.value = tempo

	# StatBlock._init() connects Health.stat_changed to a lambda that captures
	# the StatBlock itself. That RefCounted self-cycle leaks the resource, so
	# break it; Block.maxValue is set explicitly above instead.
	for conn in sb.Health.stat_changed.get_connections():
		sb.Health.stat_changed.disconnect(conn.callable)
	return sb


## A component-less card. Real action scenes have components that would damage
## the stub player when activated, so tests use this for activation paths.
static func card(action: int = Const.Actions.SLASH, cost: int = 1) -> CardData:
	var c: CardData = load("res://entities/card_datas/card_data.tscn").instantiate()
	c.actionType = action
	c.tempoCost = cost
	return c


## Builds an EnemyData that authors its deck through `card_deck_types`, which is
## the path real enemy data scenes use. `EntityData.config()` then instantiates
## the cards through ObjManager.
static func enemy_data(stats: StatBlock, types: Array = []) -> EnemyData:
	var d: EnemyData = load("res://entities/enemies/enemy_data.tscn").instantiate()
	d.entity_name = "Test Enemy"
	d.type = Const.Enemies.SLIME
	d.default_stats = stats
	d.card_deck_types.assign(types)
	return d
