extends Node2D

func _ready() -> void:
	MusicPlayer.play_bgm(
		load("res://Assets/Audio/SFC LOBBY.ogg")
	)
