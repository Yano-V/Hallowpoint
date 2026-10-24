extends Node2D

func _ready() -> void:
	MusicPlayer.play_bgm(
		load("res://Assets/Audio/TYK-2.ogg")
	)
