
extends Control


func _ready():
	await get_tree().create_timer(2.0).timeout

	# Stop background music when entering actual gameplay.
	MusicPlayer.stop()

	# Load the gameplay scene.
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
