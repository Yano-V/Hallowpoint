
extends Node2D

@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	if GameState.return_to_pause:
		$UI/Pause.show()
		get_tree().paused = true
		GameState.return_to_pause = false


func _on_pause_btn_pressed() -> void:
	$UI/Pause.show()
	get_tree().paused = true


func change_map(map_path: String, spawn_name: String = "PlayerSpawn") -> void:
	var map_resource = load(map_path) as PackedScene

	if map_resource == null:
		push_error("Could not load map: " + map_path)
		return

	var new_map = map_resource.instantiate()
	var spawn = new_map.find_child(spawn_name, true, false) as Marker2D

	if spawn == null:
		push_error("Spawn marker not found: " + spawn_name)
		new_map.free()
		return

	# Remove the current map, but keep Player and UI.
	for child in get_children():
		if child != player and child.name != "UI":
			remove_child(child)
			child.queue_free()

	# Add the destination map.
	new_map.name = map_resource.resource_path.get_file().get_basename()
	add_child(new_map)

	# Place the persistent player at the destination spawn.
	player.global_position = spawn.global_position
