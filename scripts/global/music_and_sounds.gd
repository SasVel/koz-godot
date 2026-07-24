extends Node

enum Sounds {
	None,
	Slash,
	Bonk,
	ClothMetal,
	AcidBurn,
	CardFlick
}

enum Music {
	Chill,
	Battle
}

@onready var music_track_type : Music = Music.Chill
var curr_music_player : AudioStreamPlayer

@export var sounds_dict : Dictionary[Sounds, AudioStream]

func play(sound : Sounds):
	if sound == Sounds.None: return
	var player = AudioStreamPlayer.new()
	player.bus = "SFX"
	player.autoplay = true
	player.stream = sounds_dict[sound]
	player.finished.connect(func(): player.queue_free())
	self.add_child(player)

func play_music(track_type : Music, is_forced = false):
	if !is_forced and music_track_type == track_type: return

	music_track_type = track_type
	if curr_music_player != null:
		curr_music_player.playing = false

	match music_track_type:
		Music.Chill:
			curr_music_player = %ChillMusicPlayer
		Music.Battle:
			curr_music_player = %BattleMusicPlayer
	curr_music_player.playing = true
