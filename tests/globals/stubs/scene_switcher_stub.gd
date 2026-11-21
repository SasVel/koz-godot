extends Control


# The real switcher runs a two second transition tween and changes scenes.
# Tests only care that the controller requests a transition.
func switch_transition(_isOn: bool) -> void:
	pass


func switch_to_scene(_scene: PackedScene) -> void:
	pass


func switch_to_file(_path: String) -> void:
	pass


func fake_switch(_duration: float) -> void:
	pass
