extends Node2D

func _ready() -> void:
	MusicPlayer.play_bgm(
		load("res://Assets/Audio/LBLobby-2ndFloor-1.ogg")
	)
