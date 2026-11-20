
extends Area2D

enum InteractionType {
	DIALOGUE,
	BLOCKED,
	LOCKED
}

# INTERACTION SETTINGS
@export var interaction_type: InteractionType = InteractionType.DIALOGUE
@export_multiline var dialogue_text: String = "There is nothing interesting here."
@export var required_item: String = "Key"
@export_multiline var unlocked_message: String = "You unlocked the way."

# OPTIONAL AUTOMATIC MAP TRANSITION
@export var auto_transition_when_unlocked: bool = false
@export_file("*.tscn") var next_map: String
@export var destination_spawn: String = "PlayerSpawn"

# UI REFERENCES
var interaction_prompt: Label
var player_nearby: bool = false
var transitioning: bool = false


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
	if not body.is_in_group("player"):
		return

	player_nearby = true

	# AUTOMATICALLY ENTER IF REQUIREMENT IS MET
	if interaction_type == InteractionType.LOCKED:
		if auto_transition_when_unlocked:
			if GameManager.has_item(required_item):
				transition_to_next_map()
				return

	if interaction_prompt:
		interaction_prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_nearby = false

	if interaction_prompt:
		interaction_prompt.hide()


func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby or transitioning:
		return

	if not event.is_action_pressed("interact"):
		return

	var dialogue = get_tree().get_first_node_in_group(
        "dialogue_ui"
	)

	if dialogue and dialogue.visible:
		return

	interact()

	if interaction_prompt:
		interaction_prompt.hide()

	get_viewport().set_input_as_handled()


func interact() -> void:
	var dialogue = get_tree().get_first_node_in_group(
        "dialogue_ui"
	)

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
			if GameManager.has_item(required_item):
				if auto_transition_when_unlocked:
					transition_to_next_map()
					return

				message = unlocked_message
			else:
				var article := "an" if required_item.to_lower().begins_with("a") \
					or required_item.to_lower().begins_with("e") \
					or required_item.to_lower().begins_with("i") \
					or required_item.to_lower().begins_with("o") \
					or required_item.to_lower().begins_with("u") else "a"

				message = "Needs " + article + " " + required_item + " to continue."

	dialogue.show_message(message, speaker_name)


func transition_to_next_map() -> void:
	if transitioning:
		return

	if next_map.is_empty():
		push_error("Next Map is not assigned!")
		return

	transitioning = true

	if interaction_prompt:
		interaction_prompt.hide()

	var game = get_tree().current_scene

	if game and game.has_method("change_map"):
		game.call_deferred(
			"change_map",
			next_map,
			destination_spawn
		)
	else:
		transitioning = false
		push_error("Game.gd change_map() function not found!")
