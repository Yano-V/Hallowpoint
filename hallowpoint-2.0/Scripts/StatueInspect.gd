
extends Control

var current_player: Node2D
var dialogue_box: Control

@onready var statue_view: TextureRect = $StatueView


func _ready() -> void:
	add_to_group("StatueInspectUI")
	hide()

	dialogue_box = get_tree().get_first_node_in_group("dialogue_ui")

	if dialogue_box:
		dialogue_box.connect(
			"dialogue_closed",
			_on_dialogue_closed
		)
	else:
		push_warning("DialogueBox not found!")


func show_statue(
	statue_name: String,
	dialogue: String,
	texture: Texture2D,
	player: Node2D
) -> void:

	if dialogue_box == null:
		return

	current_player = player

	# Stop player movement.
	current_player.set_process(false)
	current_player.set_physics_process(false)

	# Show statue close-up.
	statue_view.texture = texture
	show()

	# Use the EXISTING dialogue box.
	dialogue_box.show_message(dialogue, statue_name)


func _on_dialogue_closed() -> void:
	# Hide statue inspection view.
	hide()

	# Restore player movement.
	if is_instance_valid(current_player):
		current_player.set_process(true)
		current_player.set_physics_process(true)

	current_player = null
