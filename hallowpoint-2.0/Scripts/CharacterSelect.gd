
extends Control

var selected_character = ""


func _ready() -> void:
	pivot_offset = size / 2


func _on_button_pressed() -> void:
	# BACK BUTTON
	# Return to Main Menu without stopping background music.
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_ente_rbtn_pressed() -> void:
	var player_name = $UNPopUp/UsernameInput.text.strip_edges()

	if player_name == "":
		print("Please enter a username!")
		return

	GameManager.player_name = player_name

	print("Player Name: ", GameManager.player_name)
	print("Character: ", GameManager.selected_character)

	# Continue to Loading Screen.
	# Background music keeps playing.
	get_tree().change_scene_to_file("res://Scenes/LoadingScreen.tscn")


func _on_back_btn_pressed() -> void:
	# Return to Main Menu without stopping background music.
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_cancelbtn_pressed() -> void:
	# Hide the username popup.
	$UNPopUp.visible = false

	# Unlock both buttons so they can be hovered and clicked again.
	$BOYbtn.unlock_button()
	$GIRLbtn.unlock_button()

	# Clear the username input.
	$UNPopUp/UsernameInput.text = ""


func _on_boybtn_pressed() -> void:
	GameManager.selected_character = "boy"

	# Keep Boy selected.
	$BOYbtn.button_pressed = true
	$GIRLbtn.button_pressed = false

	# Show the username popup.
	$UNPopUp.visible = true
	$UNPopUp/UsernameInput.grab_focus()

	# Lock the selected button.
	$BOYbtn.lock_button(true)
	$GIRLbtn.lock_button(false)

	print("Selected character: ", GameManager.selected_character)


func _on_girlbtn_pressed() -> void:
	GameManager.selected_character = "girl"

	# Keep Girl selected.
	$BOYbtn.button_pressed = false
	$GIRLbtn.button_pressed = true

	# Show the username popup.
	$UNPopUp.visible = true
	$UNPopUp/UsernameInput.grab_focus()

	# Lock the selected button.
	$BOYbtn.lock_button(false)
	$GIRLbtn.lock_button(true)

	print("Selected character: ", GameManager.selected_character)
