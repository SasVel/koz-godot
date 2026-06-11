extends EffectComponent
class_name ComponentsData

func config_source(source_ : Entity):
	super(source_)
	for component in %Components.get_children():
		component.config_source(source_)

func add_target(target_ : Entity):
	super(target_)
	for component in %Components.get_children():
		component.add_target(target_)

func add_targets(targets_ : Array[Entity]):
	super(targets_)
	for component in %Components.get_children():
		component.add_targets(targets_)

func config(source_ : Entity, targets_ : Array[Entity]):
	super(source_, targets_)
	for component in %Components.get_children():
		config_comp(component, source_, targets_)

func config_comp(component : EffectComponent, source_ : Entity, targets_ : Array[Entity]):
	component.config(source_, targets_)

func activate():
	for component in %Components.get_children():
		component.activate()
	super()

func deactivate():
	for component in %Components.get_children():
		component.deactivate()
	super()

func generate_desc() -> String:
	var resArr : Array[String]
	for component in %Components.get_children():
		resArr.append(component.generate_desc())

	return "\n".join(resArr) if resArr.size() > 0 else ""
