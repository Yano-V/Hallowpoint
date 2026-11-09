
extends Area2D

@export_file("*.tscn") var target_scene: String = ""
@export var destination_spawn: String = "PlayerSpawn"

var transitioning := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if transitioning:
		return

	if body.name != "Player":
		return

	if target_scene.is_empty():
		push_warning("No target scene assigned to MapExit!")
		return

	var game = get_tree().current_scene

	if not game.has_method("change_map"):
		push_error("The current scene does not have a change_map() function!")
		return

	# Resolve the destination UID to its resource path.
	var destination_path := target_scene

	if target_scene.begins_with("uid://"):
		var resource_id := ResourceUID.text_to_id(target_scene)
		destination_path = ResourceUID.get_id_path(resource_id)

	print("Target path: ", destination_path)

	var destination_name := destination_path.get_file().to_lower()

	if destination_name == "tunnel1.tscn":
		print("TUNNEL1 detected! Stopping TYK music.")
		MusicPlayer.stop_bgm()
		print("Music playing after stop: ", MusicPlayer.playing)

	transitioning = true
	game.change_map(target_scene, destination_spawn)
