
extends Control

signal inspection_closed
signal master_key_collected

# ==================================================
# NODE REFERENCES
# ==================================================

@onready var opened_yearbook: TextureRect = $OpenedYearbook
@onready var master_key: TextureRect = $MasterKey
@onready var magnifying_glass: TextureRect = $MagnifyingGlass
@onready var hidden_mark: Label = $HiddenMark

@onready var left_page_area: Control = $LeftPageArea
@onready var compartment_area: Control = $CompartmentArea

@onready var text_panel: PanelContainer = $TextPanel
@onready var inspection_text: Label = $TextPanel/InspectionText
@onready var close_button: Button = $CloseButton

# ==================================================
# VARIABLES
# ==================================================

var magnifying_active: bool = false
var mark_revealed: bool = false
var key_collected: bool = false


# ==================================================
# READY
# ==================================================

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Restore previous progress.
	mark_revealed = GameManager.library_hidden_mark_found
	key_collected = GameManager.has_item("Master Key")

	# Show opened Yearbook.
	opened_yearbook.show()
	opened_yearbook.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Magnifying Glass starts hidden.
	magnifying_glass.hide()
	magnifying_glass.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Hidden inscription.
	hidden_mark.visible = mark_revealed
	hidden_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Master Key.
	master_key.visible = not key_collected
	master_key.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Interactive areas.
	left_page_area.mouse_filter = Control.MOUSE_FILTER_STOP
	compartment_area.mouse_filter = Control.MOUSE_FILTER_STOP

	# Text panel.
	text_panel.show()
	text_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inspection_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inspection_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Connect signals.
	left_page_area.gui_input.connect(_on_left_page_input)
	compartment_area.gui_input.connect(_on_compartment_input)
	close_button.pressed.connect(close_inspection)

	# Initial message.
	if key_collected:
		show_inspection_text(
			"The compartment is empty. "
			+ "You already collected the Master Key."
		)

	elif mark_revealed:
		show_inspection_text(
			"The hidden inscription remains visible. "
			+ "Click the compartment to retrieve the key."
		)

	else:
		show_inspection_text(
			"An old 1974 Yearbook. "
			+ "A hollow compartment lies on the right."
		)


# ==================================================
# INSPECTION TEXT
# ==================================================

func show_inspection_text(message: String) -> void:
	inspection_text.text = message
	text_panel.show()


# ==================================================
# MAGNIFYING GLASS MOVEMENT
# ==================================================

func _process(_delta: float) -> void:
	if magnifying_active:
		magnifying_glass.global_position = (
			get_global_mouse_position()
			- magnifying_glass.size / 2.0
		)


# ==================================================
# INPUT
# ==================================================

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_M:
				toggle_magnifying_glass()
				get_viewport().set_input_as_handled()


# ==================================================
# MAGNIFYING GLASS
# ==================================================

func toggle_magnifying_glass() -> void:
	if key_collected:
		show_inspection_text(
			"The Master Key has already been collected."
		)
		return

	if mark_revealed:
		show_inspection_text(
			"The hidden inscription has already been revealed. "
			+ "Click the compartment to collect the key."
		)
		return

	if not GameManager.has_item("Magnifying Glass"):
		show_inspection_text(
			"I need the Magnifying Glass to examine these pages."
		)
		return

	magnifying_active = not magnifying_active
	magnifying_glass.visible = magnifying_active

	if magnifying_active:
		show_inspection_text(
			"Move the Magnifying Glass over the left page."
		)
	else:
		show_inspection_text(
			"Magnifying Glass put away. "
			+ "Press M to use it again."
		)


# ==================================================
# LEFT PAGE INTERACTION
# ==================================================

func _on_left_page_input(event: InputEvent) -> void:
	if mark_revealed:
		return

	if not magnifying_active:
		return

	if event is InputEventMouseMotion:
		reveal_hidden_mark()


# ==================================================
# REVEAL HIDDEN INSCRIPTION
# ==================================================

func reveal_hidden_mark() -> void:
	if mark_revealed:
		return

	mark_revealed = true
	GameManager.library_hidden_mark_found = true

	hidden_mark.show()

	magnifying_active = false
	magnifying_glass.hide()

	show_inspection_text(
		"A hidden inscription appears! "
		+ "The compartment's mechanism unlocks."
	)

	print("YEARBOOK HIDDEN MARK REVEALED")


# ==================================================
# COMPARTMENT INTERACTION
# ==================================================

func _on_compartment_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if not event.pressed:
		return

	if key_collected:
		show_inspection_text(
			"The compartment is empty."
		)
		return

	if not mark_revealed:
		show_inspection_text(
			"The Master Key is secured by a hidden mechanism. "
			+ "Press M to examine the left page."
		)
		return

	collect_master_key()


# ==================================================
# COLLECT MASTER KEY
# ==================================================

func collect_master_key() -> void:
	if key_collected:
		return

	key_collected = true

	# Add item to inventory.
	GameManager.add_item("Master Key")
	GameManager.library_master_key_collected = true

	# Remove key from the Yearbook.
	master_key.hide()

	show_inspection_text(
		"Master Key obtained!"
	)

	print("MASTER KEY COLLECTED!")

	master_key_collected.emit()


# ==================================================
# CLOSE INSPECTION
# ==================================================

func close_inspection() -> void:
	magnifying_active = false
	magnifying_glass.hide()

	inspection_closed.emit()
	queue_free()
