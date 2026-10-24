
extends Area2D

@onready var player: CharacterBody2D = get_tree().current_scene.get_node("Player")

var grass_overlaps: int = 0


func _ready() -> void:
	# Connect the parent GrassZone itself
	body_entered.connect(_on_grass_entered.bind(self))
	body_exited.connect(_on_grass_exited.bind(self))

	# Connect all child grass zones
	for zone in get_children():
		if zone is Area2D:
			zone.body_entered.connect(_on_grass_entered.bind(zone))
			zone.body_exited.connect(_on_grass_exited.bind(zone))


func _on_grass_entered(body: Node2D, zone: Area2D) -> void:
	if body == player:
		grass_overlaps += 1
		print("ENTERED grass: ", zone.name)
		player.enter_footstep_surface("grass")


func _on_grass_exited(body: Node2D, zone: Area2D) -> void:
	if body == player:
		grass_overlaps = max(0, grass_overlaps - 1)
		print("EXITED grass: ", zone.name)
		player.exit_footstep_surface("grass")
