extends Node2D


func _ready():
	MusicManager.stop_music()
	
	if GameState.return_to_pause:
		$UI/Pause.show()
		get_tree().paused = true
		GameState.return_to_pause = false


func _on_pause_btn_pressed() -> void:
	$UI/Pause.show()
	get_tree().paused = true
