
extends Area2D

@onready var player: CharacterBody2D = get_tree().current_scene.get_node("Player")

var concrete_overlaps: int = 0


func _ready() -> void:
	# Connect the parent ConcreteZone itself
	body_entered.connect(_on_concrete_entered.bind(self))
	body_exited.connect(_on_concrete_exited.bind(self))

	# Connect all child concrete zones
	for zone in get_children():
		if zone is Area2D:
			zone.body_entered.connect(_on_concrete_entered.bind(zone))
			zone.body_exited.connect(_on_concrete_exited.bind(zone))


func _on_concrete_entered(body: Node2D, zone: Area2D) -> void:
	if body == player:
		concrete_overlaps += 1
		print("ENTERED concrete: ", zone.name)
		player.enter_footstep_surface("concrete")


func _on_concrete_exited(body: Node2D, zone: Area2D) -> void:
	if body == player:
		concrete_overlaps = max(0, concrete_overlaps - 1)
		print("EXITED concrete: ", zone.name)
		player.exit_footstep_surface("concrete")
