class_name BaseMap
extends Node2D

@export var player_scene: PackedScene = preload("res://Scenes/Player.tscn")

func _ready() -> void:
	# Release UI focus and ensure tree is unpaused
	get_viewport().gui_release_focus()
	get_tree().paused = false

	# Spawn player if missing
	spawn_player()

func spawn_player() -> void:
	if not has_node("Player"):
		if player_scene:
			var player = player_scene.instantiate()
			player.name = "Player"
			
			# Assign group so DoorTransitions work on all maps
			player.add_to_group("Player")
			
			# Set position to SpawnPoint marker if available
			if has_node("SpawnPoint"):
				player.global_position = $SpawnPoint.global_position
			
			player.z_index = 10
			add_child(player)
		else:
			push_error("BaseMap: Failed to load player_scene!")
