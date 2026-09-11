extends Control


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func _on_resum_ebtn_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_restar_tbtn_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_men_ubtn_pressed() -> void:
	get_tree().paused = false
	GameState.return_to_pause = true
	get_tree().change_scene_to_file("res://Scenes/MENU2.tscn")


func _on_setting_sbtn_pressed() -> void:
	get_tree().paused = false
	GameState.settings_return_to = "PAUSE"
	GameState.return_to_pause = true
	get_tree().change_scene_to_file("res://Scenes/SETTINGS.tscn")
