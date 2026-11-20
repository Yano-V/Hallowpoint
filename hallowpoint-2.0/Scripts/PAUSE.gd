
extends Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func _on_resum_ebtn_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	hide()


func _on_restar_tbtn_pressed() -> void:
	# Resume the scene tree before restarting.
	get_tree().paused = false

	# Hide the pause menu.
	hide()

	# Hide the cursor during gameplay.
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	# Identify the current stage.
	var stage_name: String = GameState.current_stage

	# Reset stage-specific inventory and puzzle progress.
	GameManager.reset_stage(stage_name)

	# Restart from the beginning of the current stage.
	var game = get_tree().current_scene

	if game != null and game.has_method("restart_current_stage"):
		game.restart_current_stage()
	else:
		push_error(
			"Game.gd is missing restart_current_stage()."
		)


func _on_men_ubtn_pressed() -> void:
	get_tree().paused = false
	GameState.return_to_pause = true
	get_tree().change_scene_to_file(
		"res://Scenes/MENU2.tscn"
	)


func _on_setting_sbtn_pressed() -> void:
	get_tree().paused = false
	GameState.settings_return_to = "PAUSE"
	GameState.return_to_pause = true
	get_tree().change_scene_to_file(
		"res://Scenes/SETTINGS.tscn"
	)
