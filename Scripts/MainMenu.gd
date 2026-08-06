extends Control
func _ready():
	pass

func _on_bell_timer_timeout() -> void:
	$BellSound.play() # Replace with function body.


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Settings.tscn") # Replace with function body.


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn") # Replace with function body.
