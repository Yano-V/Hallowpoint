
extends Control

signal dialogue_closed

@onready var message_label: Label = $Background/MessageLabel
@onready var continue_label: Label = $Background/ContinueLabel
@onready var name_label: Label = $Background/NameLabel
@onready var inspect_label: Label = $Background/InspectLabel

var dialogue_active: bool = false
var fade_tween: Tween

# Inspection settings
var inspectable_item: bool = false
var current_inspection_texture: Texture2D
var current_readable_text: String = ""

# Opening settings
var current_can_open: bool = false
var current_opened_texture: Texture2D

# Contained item settings
var current_contains_item: bool = false
var current_contained_item_name: String = ""
var current_contained_item_texture: Texture2D

var inspection_open: bool = false


func _ready() -> void:
	add_to_group("dialogue_ui")

	hide()
	name_label.hide()
	inspect_label.hide()


func show_message(
	message: String,
	speaker_name: String = ""
) -> void:
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()

	reset_inspection()

	message_label.text = message

	if speaker_name != "":
		name_label.text = speaker_name
		name_label.show()
	else:
		name_label.text = ""
		name_label.hide()

	continue_label.text = "Press E to continue"
	continue_label.show()

	modulate.a = 0.0
	show()
	dialogue_active = true

	fade_tween = create_tween()
	fade_tween.tween_property(
		self, "modulate:a", 1.0, 0.5
	)


func enable_inspection(
	texture: Texture2D,
	readable_text: String = "",
	can_open: bool = false,
	opened_texture: Texture2D = null,
	contains_item: bool = false,
	contained_item_name: String = "",
	contained_item_texture: Texture2D = null
) -> void:
	if texture == null:
		return

	inspectable_item = true
	current_inspection_texture = texture
	current_readable_text = readable_text

	current_can_open = can_open
	current_opened_texture = opened_texture

	current_contains_item = contains_item
	current_contained_item_name = contained_item_name
	current_contained_item_texture = contained_item_texture

	inspect_label.text = "Press F to inspect"
	inspect_label.show()


func _unhandled_input(event: InputEvent) -> void:
	if not dialogue_active or inspection_open:
		return

	if event.is_echo():
		return

	if event.is_action_pressed("inspect") and inspectable_item:
		var inspection_ui = get_tree().get_first_node_in_group(
			"item_inspect_ui"
		)

		if inspection_ui:
			inspection_open = true

			# Stop the fade animation before hiding.
			if fade_tween and fade_tween.is_running():
				fade_tween.kill()

			hide()

			inspection_ui.show_item(
				current_inspection_texture,
				current_readable_text,
				current_can_open,
				current_opened_texture,
				current_contains_item,
				current_contained_item_name,
				current_contained_item_texture
			)
		else:
			push_warning("ItemInspectUI not found!")

		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("interact"):
		close_dialogue()
		get_viewport().set_input_as_handled()


func return_from_inspection() -> void:
	inspection_open = false

	if fade_tween and fade_tween.is_running():
		fade_tween.kill()

	modulate.a = 1.0
	show()


func close_dialogue() -> void:
	if not dialogue_active or inspection_open:
		return

	dialogue_active = false

	if fade_tween and fade_tween.is_running():
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.tween_property(
		self, "modulate:a", 0.0, 0.4
	)

	fade_tween.tween_callback(_finish_closing)


# Used when the player keeps the contained item.
func finish_inspection_and_close() -> void:
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()

	dialogue_active = false
	inspection_open = false

	modulate.a = 1.0
	hide()
	name_label.hide()

	reset_inspection()

	dialogue_closed.emit()


func _finish_closing() -> void:
	hide()
	name_label.hide()

	reset_inspection()

	dialogue_closed.emit()


func reset_inspection() -> void:
	inspectable_item = false
	inspection_open = false

	current_inspection_texture = null
	current_readable_text = ""

	current_can_open = false
	current_opened_texture = null

	current_contains_item = false
	current_contained_item_name = ""
	current_contained_item_texture = null

	inspect_label.hide()
