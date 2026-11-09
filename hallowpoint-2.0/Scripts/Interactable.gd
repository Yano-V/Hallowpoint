
extends Area2D

enum InteractionType {
	DIALOGUE,
	BLOCKED,
	LOCKED
}

# Interaction settings
@export var interaction_type: InteractionType = InteractionType.DIALOGUE
@export_multiline var dialogue_text: String = "There is nothing interesting here."
@export var required_item: String = "Key"
@export_multiline var unlocked_message: String = "You unlocked the way."

# UI references
var interaction_prompt: Label
var player_nearby: bool = false


func _ready() -> void:
	interaction_prompt = get_tree().get_first_node_in_group(
		"interaction_prompt"
	) as Label

	if interaction_prompt:
		interaction_prompt.hide()
	else:
		push_warning("InteractionPrompt not found!")

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true

		if interaction_prompt:
			interaction_prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false

		if interaction_prompt:
			interaction_prompt.hide()


func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby:
		return

	if not event.is_action_pressed("interact"):
		return

	var dialogue = get_tree().get_first_node_in_group("dialogue_ui")

	if dialogue and dialogue.visible:
		return

	interact()

	if interaction_prompt:
		interaction_prompt.hide()

	get_viewport().set_input_as_handled()


func interact() -> void:
	var dialogue = get_tree().get_first_node_in_group("dialogue_ui")

	if not dialogue:
		push_warning("DialogueBox not found!")
		return

	var message: String = ""
	var speaker_name: String = GameManager.player_name

	match interaction_type:

		InteractionType.DIALOGUE:
			message = dialogue_text

		InteractionType.BLOCKED:
			message = "Can't access. Find another way."

		InteractionType.LOCKED:
			if GameState.inventory.has(required_item):
				message = unlocked_message
			else:
				var article := "an" if required_item.to_lower().begins_with(
					"a"
				) or required_item.to_lower().begins_with(
					"e"
				) or required_item.to_lower().begins_with(
					"i"
				) or required_item.to_lower().begins_with(
					"o"
				) or required_item.to_lower().begins_with(
					"u"
				) else "a"

				message = "Needs " + article + " " + required_item + " to continue."

	dialogue.show_message(message, speaker_name)
