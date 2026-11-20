
extends Control

enum InspectionState {
	VIEWING,
	OPENED,
	ITEM_TAKEN
}

@onready var item_image: TextureRect = $ItemImage
@onready var contained_item_image: TextureRect = $ContainedItemImage

@onready var reading_panel: PanelContainer = $ReadingPanel
@onready var reading_text: Label = $ReadingPanel/ReadingText

@onready var read_label: Label = $ReadLabel
@onready var exit_label: Label = $ExitLabel


var inspecting: bool = false
var reading: bool = false

var inspection_state: InspectionState = InspectionState.VIEWING

var current_readable_text: String = ""

var can_open: bool = false
var opened_texture: Texture2D

var contains_item: bool = false
var contained_item_name: String = ""
var contained_item_texture: Texture2D

var player: Node
var previous_input_processing: bool = true
var previous_physics_processing: bool = true


func _ready() -> void:
	add_to_group("item_inspect_ui")

	process_mode = Node.PROCESS_MODE_ALWAYS

	hide()
	reading_panel.hide()
	read_label.hide()
	contained_item_image.hide()

	exit_label.text = "Press F to return"


func show_item(
	texture: Texture2D,
	readable_text: String = "",
	item_can_open: bool = false,
	item_opened_texture: Texture2D = null,
	item_contains_item: bool = false,
	item_contained_name: String = "",
	item_contained_texture: Texture2D = null
) -> void:

	if texture == null:
		return

	# Store inspection settings.
	current_readable_text = readable_text

	can_open = item_can_open
	opened_texture = item_opened_texture

	contains_item = item_contains_item
	contained_item_name = item_contained_name
	contained_item_texture = item_contained_texture

	# Reset inspection state.
	inspection_state = InspectionState.VIEWING
	inspecting = true
	reading = false

	item_image.texture = texture
	item_image.show()

	contained_item_image.texture = contained_item_texture
	contained_item_image.hide()

	reading_panel.hide()
	reading_text.text = ""

	update_prompt()

	show()

	# Disable player movement while inspecting.
	player = get_tree().get_first_node_in_group("player")

	if player:
		previous_input_processing = player.is_processing_input()
		previous_physics_processing = player.is_physics_processing()

		player.set_process_input(false)
		player.set_physics_process(false)


func _unhandled_input(event: InputEvent) -> void:

	if not inspecting:
		return

	if event.is_echo():
		return

	if event.is_action_pressed("interact"):
		handle_interaction()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("inspect"):

		# Cannot exit while keeping the contained item.
		if inspection_state != InspectionState.ITEM_TAKEN:
			close_item(false)

		get_viewport().set_input_as_handled()


func handle_interaction() -> void:

	# Special opening sequence.
	if can_open:

		match inspection_state:

			InspectionState.VIEWING:
				open_item()

			InspectionState.OPENED:
				if contains_item:
					take_contained_item()

			InspectionState.ITEM_TAKEN:
				keep_contained_item()

		return

	# Normal readable-item behavior.
	if current_readable_text.strip_edges() != "":
		toggle_reading()


func open_item() -> void:

	if opened_texture == null:
		push_warning("Opened Texture is missing!")
		return

	item_image.texture = opened_texture

	inspection_state = InspectionState.OPENED

	# Show the contained item on top of the opened Book.
	if contains_item and contained_item_texture:
		contained_item_image.texture = contained_item_texture
		contained_item_image.show()

	update_prompt()


func take_contained_item() -> void:

	if not contains_item:
		return

	inspection_state = InspectionState.ITEM_TAKEN

	# Hide the Book, leaving the item visible.
	item_image.hide()

	contained_item_image.texture = contained_item_texture
	contained_item_image.show()

	update_prompt()


func keep_contained_item() -> void:

	if contained_item_name.strip_edges() == "":
		return

	# Register the contained item in GameManager.
	# GameManager also synchronizes GameState.inventory.
	GameManager.add_item(contained_item_name)

	print("ITEM KEPT: ", contained_item_name)

	close_item(true)


func toggle_reading() -> void:

	reading = not reading

	if reading:
		reading_text.text = current_readable_text
		reading_panel.show()
	else:
		reading_panel.hide()

	update_prompt()


func update_prompt() -> void:

	read_label.hide()

	if can_open:

		match inspection_state:

			InspectionState.VIEWING:
				read_label.text = "Press E to open"
				read_label.show()

			InspectionState.OPENED:
				if contains_item:
					read_label.text = (
						"Press E to get " + contained_item_name
					)
					read_label.show()

			InspectionState.ITEM_TAKEN:
				read_label.text = "Press E to keep"
				read_label.show()

	else:

		if current_readable_text.strip_edges() != "":

			if reading:
				read_label.text = "Press E to hide text"
			else:
				read_label.text = "Press E to read"

			read_label.show()

	if inspection_state == InspectionState.ITEM_TAKEN:
		exit_label.hide()
	else:
		exit_label.text = "Press F to return"
		exit_label.show()


func close_item(finish_sequence: bool = false) -> void:

	if not inspecting:
		return

	inspecting = false
	reading = false

	hide()
	reading_panel.hide()
	contained_item_image.hide()

	# Restore player's previous input settings.
	if is_instance_valid(player):
		player.set_process_input(previous_input_processing)
		player.set_physics_process(previous_physics_processing)

	player = null

	var dialogue = get_tree().get_first_node_in_group(
		"dialogue_ui"
	)

	if dialogue:

		if finish_sequence:
			# Return directly to gameplay after keeping item.
			dialogue.finish_inspection_and_close()
		else:
			# Return to the pickup dialogue.
			dialogue.return_from_inspection()


# ==================================================
# RESET INSPECTION
# ==================================================

func reset_inspection() -> void:
	# Restore player processing if inspection is active.
	if is_instance_valid(player):
		player.set_process_input(previous_input_processing)
		player.set_physics_process(previous_physics_processing)

	player = null

	# Reset inspection flags.
	inspecting = false
	reading = false

	inspection_state = InspectionState.VIEWING

	# Clear stored inspection information.
	current_readable_text = ""

	can_open = false
	opened_texture = null

	contains_item = false
	contained_item_name = ""
	contained_item_texture = null

	# Reset images.
	item_image.texture = null
	item_image.show()

	contained_item_image.texture = null
	contained_item_image.hide()

	# Reset reading interface.
	reading_text.text = ""
	reading_panel.hide()
	read_label.hide()

	exit_label.text = "Press F to return"
	exit_label.show()

	hide()

	print("ITEM INSPECTION RESET!")
