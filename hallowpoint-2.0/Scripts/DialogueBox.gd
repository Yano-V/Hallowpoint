
extends Control

@onready var message_label: Label = $Background/MessageLabel
@onready var continue_label: Label = $Background/ContinueLabel
@onready var name_label: Label = $Background/NameLabel

var dialogue_active: bool = false
signal dialogue_closed

func _ready() -> void:
	add_to_group("dialogue_ui")
	visible = false
	name_label.visible = false


func show_message(message: String, speaker_name: String = "") -> void:
	message_label.text = message

	if speaker_name != "":
		name_label.text = speaker_name
		name_label.visible = true
	else:
		name_label.text = ""
		name_label.visible = false

	continue_label.text = "Press E to continue"
	continue_label.visible = true

	visible = true
	dialogue_active = true


func _unhandled_input(event: InputEvent) -> void:
	if dialogue_active and event.is_action_pressed("interact") and not event.is_echo():
		close_dialogue()
		get_viewport().set_input_as_handled()


func close_dialogue() -> void:
	if not dialogue_active:
		return

	visible = false
	dialogue_active = false
	name_label.visible = false

	dialogue_closed.emit()
