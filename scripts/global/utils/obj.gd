extends Node
class_name Obj

static func connect_signals(sig_dict : Dictionary[Signal, Callable]):
	for sig in sig_dict:
		if not sig.is_connected(sig_dict[sig]):
			sig.connect(sig_dict[sig])

static func disconnect_signals(sig_dict : Dictionary[Signal, Callable]):
	for sig in sig_dict:
		if sig.is_connected(sig_dict[sig]):
			sig.disconnect(sig_dict[sig])

static func tween_shader_parameter(obj : Node, param_name : String, from : Variant, to : Variant, duration : float):
	var tween = obj.create_tween()
	tween.tween_method(func(val): obj.material.set_shader_parameter(param_name, val), from, to, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished
