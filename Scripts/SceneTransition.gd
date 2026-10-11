extends Area2D

@export_file("*.tscn") var target_scene: String

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and target_scene != "":
		# Defer scene execution until the physics frame finishes
		call_deferred("change_scene")

func change_scene() -> void:
	get_tree().change_scene_to_file(target_scene)
