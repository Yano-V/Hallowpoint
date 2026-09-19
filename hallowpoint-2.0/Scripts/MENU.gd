extends Control


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_sav_ebtn_pressed():
	print("Game saved!")


func _on_qui_tbtn_pressed():
	$QuitConfirmation.show()

func _on_yesbtn_pressed() -> void:
	get_tree().quit()

func _on_nobtn_pressed() -> void:
	$QuitConfirmation.hide()

func _on_mainmenu_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_setting_sbtn_pressed() -> void:
	GameState.settings_return_to = "MENU"
	get_tree().change_scene_to_file("res://Scenes/SETTINGS.tscn")


func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
