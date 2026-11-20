
extends Control

enum InspectionState {
	INACTIVE,
	DIALOGUE,
	VIEWING,
	READING
}

var inspection_state: InspectionState = InspectionState.INACTIVE

var current_player: Node2D
var dialogue_box: Control
var inspecting_rizal: bool = false

# RIZAL STATUE TEXTURES
@export var rizal_closed_texture: Texture2D
@export var rizal_opened_texture: Texture2D

# UI NODES
@onready var statue_view: TextureRect = $StatueView
@onready var stone_book: TextureRect = $StoneBook
@onready var candle_image: TextureRect = $CandleImage
@onready var shard_image: TextureRect = $ShardImage

@onready var inscription_panel: Panel = $InscriptionPanel
@onready var inscription_text: Label = $InscriptionPanel/InscriptionText

@onready var action_prompt: Label = $ActionPrompt
@onready var exit_prompt: Label = $ExitPrompt


func _ready() -> void:
	add_to_group("StatueInspectUI")

	hide()

	# Hide puzzle elements initially.
	stone_book.hide()
	candle_image.hide()
	shard_image.hide()
	inscription_panel.hide()
	action_prompt.hide()
	exit_prompt.hide()

	# Find the existing dialogue UI.
	dialogue_box = get_tree().get_first_node_in_group(
		"dialogue_ui"
	)

	if dialogue_box:
		if not dialogue_box.dialogue_closed.is_connected(
			_on_dialogue_closed
		):
			dialogue_box.dialogue_closed.connect(
				_on_dialogue_closed
			)
	else:
		push_warning("DialogueBox not found!")


func show_statue(
	statue_name: String,
	dialogue: String,
	texture: Texture2D,
	player: Node2D,
	is_rizal: bool = false
) -> void:

	if dialogue_box == null:
		return

	if inspection_state != InspectionState.INACTIVE:
		return

	current_player = player
	inspecting_rizal = is_rizal

	# Disable player movement.
	current_player.set_process(false)
	current_player.set_physics_process(false)

	# Reset UI.
	stone_book.hide()
	candle_image.hide()
	shard_image.hide()
	inscription_panel.hide()
	action_prompt.hide()
	exit_prompt.hide()

	# Apply the selected statue's texture.
	statue_view.texture = texture

	if inspecting_rizal:
		GameManager.rizal_first_inspected = true
		update_rizal_appearance()

	show()

	inspection_state = InspectionState.DIALOGUE

	# Wait before displaying dialogue.
	await get_tree().create_timer(0.3).timeout

	if inspection_state == InspectionState.DIALOGUE:
		dialogue_box.show_message(
			dialogue,
			statue_name
		)


func _on_dialogue_closed() -> void:
	if inspection_state != InspectionState.DIALOGUE:
		return

	inspection_state = InspectionState.VIEWING

	update_prompts()


func update_rizal_appearance() -> void:
	if not inspecting_rizal:
		return

	# Stone Book appears after collecting Book Receipt.
	stone_book.visible = (
		GameManager.has_item("Book Receipt")
	)

	if GameManager.rizal_candle_placed:

		# Show lit candle.
		candle_image.show()

		# Switch statue to opened-base texture.
		if rizal_opened_texture != null:
			statue_view.texture = rizal_opened_texture
			print("RIZAL: Opened-base texture applied!")
		else:
			push_error(
				"RIZAL: RIZAL-OPEN texture is not assigned!"
			)

		# Reveal shard inside opened compartment.
		shard_image.visible = (
			not GameManager.rizal_shard_collected
		)

	else:

		# Keep candle hidden.
		candle_image.hide()

		# Keep statue base closed.
		if rizal_closed_texture != null:
			statue_view.texture = rizal_closed_texture
		else:
			push_warning(
				"RIZAL: Closed-base texture is not assigned!"
			)

		# Keep shard hidden.
		shard_image.hide()


func get_available_action() -> String:
	if not inspecting_rizal:
		return ""

	# Shard is available after candle placement.
	if GameManager.rizal_candle_placed:

		if not GameManager.rizal_shard_collected:
			return "collect_shard"

		return ""

	# Require Book Receipt before stone book appears.
	if not GameManager.has_item("Book Receipt"):
		return ""

	# Examine stone book.
	if not GameManager.rizal_stone_book_read:
		return "examine_book"

	# Place candle after discovering the clue.
	if GameManager.has_item("Votive Candle"):
		return "place_candle"

	return ""


func update_prompts() -> void:
	action_prompt.hide()
	exit_prompt.hide()

	if inspection_state == InspectionState.READING:
		action_prompt.text = "E - Finish reading"
		action_prompt.show()

		exit_prompt.text = "Press F to exit the scene"
		exit_prompt.show()
		return

	if inspection_state != InspectionState.VIEWING:
		return

	var action := get_available_action()

	match action:
		"examine_book":
			action_prompt.text = "E - Examine Stone Book"

		"place_candle":
			action_prompt.text = "E - Light and place the candle"

		"collect_shard":
			action_prompt.text = "E - Collect Shard"

	if action != "":
		action_prompt.show()
		exit_prompt.text = "Press F to exit the scene"
	else:
		exit_prompt.text = "Press E to exit the scene"

	exit_prompt.show()


func examine_stone_book() -> void:
	inspection_state = InspectionState.READING

	if GameManager.has_item("Magnifying Glass"):

		inscription_text.text = (
			"Where knowledge rests in stone, "
			+ "a flame shall reveal what lies beneath. "
			+ "Offer a light at the feet of the forgotten."
		)

		GameManager.rizal_stone_book_read = true

	else:

		inscription_text.text = (
			"The inscriptions are too faint to read. "
			+ "Perhaps something could help me "
			+ "examine them."
		)

	inscription_panel.show()

	update_prompts()


func finish_reading() -> void:
	inscription_panel.hide()

	inspection_state = InspectionState.VIEWING

	update_prompts()


func place_rizal_candle() -> void:
	if not GameManager.rizal_stone_book_read:
		return

	if not GameManager.has_item("Votive Candle"):
		return

	# Remove candle from inventory.
	GameManager.remove_item("Votive Candle")

	# Record puzzle progress.
	GameManager.rizal_candle_placed = true

	print("RIZAL: Votive Candle placed and lit!")

	# Reveal candle, opened base, and shard.
	update_rizal_appearance()

	# Change interaction prompt.
	update_prompts()


func collect_rizal_shard() -> void:
	if not GameManager.rizal_candle_placed:
		return

	if GameManager.rizal_shard_collected:
		return

	# Add shard to inventory.
	GameManager.add_item("Rizal Shard")

	GameManager.rizal_shard_collected = true

	# Remove shard image.
	shard_image.hide()

	print("RIZAL SHARD COLLECTED!")

	update_prompts()


func _unhandled_input(event: InputEvent) -> void:
	if inspection_state != InspectionState.VIEWING \
	and inspection_state != InspectionState.READING:
		return

	if event is not InputEventKey:
		return

	if not event.pressed or event.is_echo():
		return

	# F exits the inspection.
	if event.keycode == KEY_F:
		if inspecting_rizal:
			close_inspection()
			get_viewport().set_input_as_handled()
		return

	if not event.is_action_pressed("interact"):
		return

	get_viewport().set_input_as_handled()

	# Close the inscription panel.
	if inspection_state == InspectionState.READING:
		finish_reading()
		return

	var action := get_available_action()

	match action:

		"examine_book":
			examine_stone_book()

		"place_candle":
			place_rizal_candle()

		"collect_shard":
			collect_rizal_shard()

		_:
			close_inspection()


func close_inspection() -> void:
	inspection_state = InspectionState.INACTIVE

	# Hide all puzzle elements.
	stone_book.hide()
	candle_image.hide()
	shard_image.hide()
	inscription_panel.hide()
	action_prompt.hide()
	exit_prompt.hide()

	hide()

	# Restore player movement.
	if is_instance_valid(current_player):
		current_player.set_process(true)
		current_player.set_physics_process(true)

	current_player = null
	inspecting_rizal = false
