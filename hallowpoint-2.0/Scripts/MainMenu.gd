extends Control
func _ready():
	pass

func _on_bell_timer_timeout() -> void:
	$BellSound.play() # Replace with function body.

func _on_star_tbutton_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/CharacterSelect.tscn")


func _on_abou_tbutton_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ABOUT.tscn")


func _on_men_ubutton_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MENU.tscn")
