extends Control

func _ready():
	$AmbientSound.play()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/intro_garden.tscn")

func _on_exit_button_pressed():
	get_tree().quit()

func _on_bell_timer_timeout():
	$BellSound.play()
