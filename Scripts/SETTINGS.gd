extends Control

@export var map_bgm: AudioStream

func _ready() -> void:
	if map_bgm:
		AudioManager.play_bgm(map_bgm)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
