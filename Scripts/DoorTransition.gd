extends Area2D

@export_file("*.tscn") var target_scene: String

func _ready() -> void:
	# Check if signal is already connected (prevents duplicate connection error)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and target_scene != "":
		# Defers scene change until the physics frame finishes
		call_deferred("change_map")

func change_map() -> void:
	get_tree().change_scene_to_file(target_scene)
