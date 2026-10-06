extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_save_btn_pressed() -> void:
	print("Game saved!")


func _on_mainmenu_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_resume_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _on_quit_btn_pressed() -> void:
	$QuitConfirmation.show()


func _on_yesbtn_pressed() -> void:
	get_tree().quit()


func _on_nobtn_pressed() -> void:
	$QuitConfirmation.hide()
