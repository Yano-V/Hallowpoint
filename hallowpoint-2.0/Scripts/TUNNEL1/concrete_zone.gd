
extends Area2D

@onready var player: CharacterBody2D = get_tree().current_scene.get_node("Player")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body == player:
		print("Entered concrete zone: ", name)
		player.enter_footstep_surface("concrete")


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		print("Exited concrete zone: ", name)
		player.exit_footstep_surface("concrete")
