extends Control

@export var map_bgm: AudioStream

func _ready() -> void:
	if map_bgm:
		AudioManager.play_bgm(map_bgm)
func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ABOUT.tscn")


func _on_main_menu_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
