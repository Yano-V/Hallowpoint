extends Node

var bgm_player: AudioStreamPlayer

func _ready() -> void:
	# Instantiates a persistent audio player that survives scene changes
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Master"
	add_child(bgm_player)

func play_bgm(audio_stream: AudioStream, volume_db: float = 0.0) -> void:
	# If the exact same track is ALREADY playing, don't interrupt or restart it
	if bgm_player.stream == audio_stream and bgm_player.playing:
		return
		
	bgm_player.stream = audio_stream
	bgm_player.volume_db = volume_db
	bgm_player.play()

func stop_bgm() -> void:
	bgm_player.stop()
