
extends Area2D

@export_file("*.tscn") var next_map: String

var transitioning := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if transitioning:
		return

	if body.name != "Player":
		return

	if next_map.is_empty():
		push_error("Next Map is not assigned!")
		return

	transitioning = true

	var game = get_tree().current_scene
	game.change_map(next_map, "PlayerSpawn")
