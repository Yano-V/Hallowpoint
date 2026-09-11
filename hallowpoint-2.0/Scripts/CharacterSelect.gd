extends Control

var selected_character = ""


func _on_button_pressed() -> void:
	# BACK BUTTON
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_ente_rbtn_pressed() -> void:
	var player_name = $UNPopUp/UsernameInput.text.strip_edges()
	
	if player_name == "":
		print("Please enter a username!")
		return

	GameManager.player_name = player_name

	print("Player Name: ", GameManager.player_name)
	print("Character: ", GameManager.selected_character)

	get_tree().change_scene_to_file("res://Scenes/LoadingScreen.tscn")


func _on_boy_pressed() -> void:
	GameManager.selected_character = "boy"
	
	# Keep Boy selected
	$BOY.button_pressed = true
	$GIRL.button_pressed = false
	
	$UNPopUp.visible = true
	$UNPopUp/UsernameInput.grab_focus()
	
	print("Selected character: ", GameManager.selected_character)


func _on_girl_pressed() -> void:
	GameManager.selected_character = "girl"
	
	# Keep Girl selected
	$BOY.button_pressed = false
	$GIRL.button_pressed = true
	
	$UNPopUp.visible = true
	$UNPopUp/UsernameInput.grab_focus()
	
	print("Selected character: ", GameManager.selected_character)


func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
