
extends Area2D

@onready var player: CharacterBody2D = get_tree().current_scene.get_node("Player")


func _ready() -> void:
	for zone in get_children():
		if zone is Area2D:
			zone.body_entered.connect(_on_concrete_entered)
			zone.body_exited.connect(_on_concrete_exited)


func _on_concrete_entered(body: Node2D) -> void:
	if body == player:
		player.enter_footstep_surface("concrete")
		print("Entered concrete: ", body.name)


func _on_concrete_exited(body: Node2D) -> void:
	if body == player:
		player.exit_footstep_surface("concrete")
		print("Exited concrete: ", body.name)
