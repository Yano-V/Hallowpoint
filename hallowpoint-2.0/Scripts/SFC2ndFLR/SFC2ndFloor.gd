extends Node2D

func _ready() -> void:
	MusicPlayer.play_bgm(
		load("res://Assets/Audio/SFC 2ND FLOOR - 1.ogg")
	)
