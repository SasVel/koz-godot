extends Node

enum Sounds {
	None,
	Slash,
	Bonk,
	ClothMetal,
	AcidBurn,
	CardFlick
}

@export var sounds_dict : Dictionary[Sounds, AudioStream]

func play(sound : Sounds):
	if sound == Sounds.None: return
	var player = AudioStreamPlayer.new()
	player.bus = "SFX"
	player.autoplay = true
	player.stream = sounds_dict[sound]
	player.finished.connect(func(): player.queue_free())
	self.add_child(player)
