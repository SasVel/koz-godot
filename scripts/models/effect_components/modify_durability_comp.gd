extends EffectComponent
class_name ModifyDurabilityComp

## Positive values increase durability, negative values decrease it.

func _ready() -> void:
	self.isOffensive = false
	self.ticker = "DUR"

func activate():
	var durability_change := process_value(value)
	for tool in Game.player.equipped_tools:
		tool.durability += durability_change
	super()

func generate_desc() -> String:
	var val := process_value(value)
	return "%s durability of tools by %d." % \
		["Increase" if val >= 0 else "Decrease", absi(val)]
