extends Control


func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn") # Replace with function body.


func _on_tutorial_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/TUTORIAL.tscn")
