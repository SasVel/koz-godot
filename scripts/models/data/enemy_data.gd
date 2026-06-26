extends EntityData
class_name EnemyData

@export var type : Const.Enemies
@export var has_alt_sprite : bool = false
@export var custom_scale_multi : float = 1.0
@export var idle_anim_settings : IdleAnimSettings

func enemy_config(source_ : Entity, targets_ : Array[Entity]):
	for component in %Components.get_children():
		component.config(source_, targets_)
	config()
