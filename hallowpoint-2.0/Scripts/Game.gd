
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var ui = $UI
@onready var tutorial = $TutorialG
var inventory: Array[String] = []


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	if GameState.return_to_pause:
		$UI/Pause.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		GameState.return_to_pause = false


func _on_pause_btn_pressed() -> void:
	$UI/Pause.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


func change_map(map_path: String, spawn_name: String = "PlayerSpawn") -> void:
	# Defer the map change until the current physics operation finishes.
	call_deferred("_change_map_deferred", map_path, spawn_name)


func _change_map_deferred(map_path: String, spawn_name: String) -> void:
	var map_resource := load(map_path) as PackedScene

	if map_resource == null:
		push_error("Could not load map: " + map_path)
		return

	var new_map := map_resource.instantiate()
	new_map.name = map_resource.resource_path.get_file().get_basename()

	# Remove the current map, but keep Player, UI, and TutorialG.
	for child in get_children():
		if child != player and child != ui and child != tutorial:
			remove_child(child)
			child.queue_free()

	# Add the destination map.
	add_child(new_map)

	# Find the requested spawn marker.
	var spawn := new_map.find_child(spawn_name, true, false) as Marker2D

	if spawn == null:
		push_error(
            "Spawn marker '%s' not found in map '%s'."
			% [spawn_name, map_path]
		)
		return

	# Print information for debugging.
	print("Destination map: ", new_map.name)
	print("Requested spawn: ", spawn_name)
	print("Found marker: ", spawn.get_path())
	print("Marker global position: ", spawn.global_position)

	# Move the persistent player to the destination.
	player.global_position = spawn.global_position
	player.velocity = Vector2.ZERO

	# Temporarily disable map exits to prevent immediate retriggering.
	await _disable_map_exits_temporarily()


func _disable_map_exits_temporarily() -> void:
	var exits := get_tree().get_nodes_in_group("map_exits")

	# Disable all exits.
	for exit in exits:
		if is_instance_valid(exit):
			exit.set_deferred("monitoring", false)

	# Wait half a second.
	await get_tree().create_timer(0.5).timeout

	# Re-enable exits that still exist.
	for exit in get_tree().get_nodes_in_group("map_exits"):
		if is_instance_valid(exit):
			exit.set_deferred("monitoring", true)

func _input(event: InputEvent) -> void:
	
	if event is InputEventKey:
		if event.pressed and not event.echo:
			
			if event.keycode == KEY_P:
				if not get_tree().paused:
					
					$UI/Pause.show()
					
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
					
					get_tree().paused = true
					
					get_viewport().set_input_as_handled()
