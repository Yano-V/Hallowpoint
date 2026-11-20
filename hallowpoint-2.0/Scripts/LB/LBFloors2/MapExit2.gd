
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

	transitioning = true
	game.change_map(target_scene, destination_spawn)
