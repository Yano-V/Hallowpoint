extends Node2D

@onready var spawn_point: Marker2D = $SpawnPoint

func _ready() -> void:
	print("--- MAP2 _ready() Started ---")
	
	# Clear any active keyboard focus from UI/menus (e.g., text inputs)
	get_viewport().gui_release_focus()
	
	# Unpause engine if coming from a paused UI scene
	get_tree().paused = false
	
	if spawn_point == null:
		push_error("SpawnPoint marker node is missing from Map2!")
		return

	if not has_node("Player"):
		var player_scene = load("res://Player.tscn") # Root directory path
		
		if player_scene:
			var player = player_scene.instantiate()
			player.name = "Player" # Guarantees has_node("Player") check works
			
			# Use global position to ensure exact placement regardless of parent transforms
			player.global_position = spawn_point.global_position
			
			# FORCE LAYER RENDERING: Draw player above ground and foreground textures
			player.z_index = 10 
			
			add_child(player)
			print("SUCCESS: Player spawned at position: ", spawn_point.global_position)
		else:
			push_error("ERROR: Could not load res://Player.tscn")
	else:
		print("Player node already exists in MAP2 scene tree.")
