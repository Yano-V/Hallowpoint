extends Node2D

func _ready() -> void:
	MusicPlayer.play_bgm(
		load("res://Assets/Audio/LIBRARY-1.ogg")
	)
