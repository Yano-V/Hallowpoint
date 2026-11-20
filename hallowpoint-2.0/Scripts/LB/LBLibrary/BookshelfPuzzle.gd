
extends Control

signal puzzle_solved
signal puzzle_closed

# ==================================================
# BOOK ORDER
# ==================================================

const CORRECT_ORDER: Array[String] = [
	"Beginnings",
	"Foundations",
	"Yearbook",
	"Growth",
	"Change",
	"The Last Pages"
]

const STARTING_ORDER: Array[String] = [
	"Growth",
	"Yearbook",
	"Change",
	"Beginnings",
	"Foundations",
	""
]

# ==================================================
# BOOK DESCRIPTIONS
# ==================================================

const BOOK_DESCRIPTIONS := {
	"Beginnings": "It began with a single building and a few classrooms. There was no Quadrangle yet, only open ground, a promise. The founders said: 'Start small, but start with heart.'",

	"Foundations": "Once the first building was full, a second was raised beside it. Students filled the hallways, and the school grew from a handful of rooms into a true campus. The founder's promise was now written in stone.",

	"Yearbook": "The Quadrangle was finished at last, and the Lualhati Statue was unveiled before the whole school. Students wore their best uniforms. The faces on these pages are smiling.",

	"Growth": "New colleges opened, and the old halls could no longer hold everyone. Taller buildings rose around the Quadrangle. Some remembered the early days fondly, but the campus kept growing.",

	"Change": "Computers arrived, and with them new classrooms and new ways to learn. Students built things in labs that the founders could never have imagined. The campus changed, but the statue stayed where it was.",

	"The Last Pages": "The last entries are hurried and unfinished. Pages are blank where the ink has run. The final line is only half-written: 'We must not forget...'"
}

# ==================================================
# EXPORTED RESOURCES
# ==================================================

@export var last_pages_texture: Texture2D
@export var yearbook_inspect_scene: PackedScene

# ==================================================
# NODE REFERENCES
# ==================================================

@onready var book_slots: Control = $BookSlots
@onready var description_panel: PanelContainer = $BookDescription
@onready var description_label: Label = $BookDescription/DescriptionLabel
@onready var close_button: Button = $CloseButton

# ==================================================
# VARIABLES
# ==================================================

var slots: Array[Control] = []
var book_textures: Dictionary = {}
var current_order: Array[String] = []

var missing_book_found := false
var is_solved := false

var dragging_from := -1
var dragging_book := ""
var drag_preview: TextureRect = null

var yearbook_inspection: Control = null

# ==================================================
# READY
# ==================================================

func _ready() -> void:
	for i in range(1, 7):
		var slot := book_slots.get_node(
			"Slot" + str(i)
		) as Control

		slots.append(slot)
		slot.mouse_filter = Control.MOUSE_FILTER_STOP

		var image := slot.get_node(
			"TextureRect"
		) as TextureRect

		image.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Register initial textures.
	for i in range(STARTING_ORDER.size()):
		var book_name := STARTING_ORDER[i]

		if book_name == "":
			continue

		var image := slots[i].get_node(
			"TextureRect"
		) as TextureRect

		if image.texture:
			book_textures[book_name] = image.texture

	# Restore arrangement.
	current_order = GameManager.get_library_book_order()
	is_solved = GameManager.library_books_arranged

	# Restore missing book.
	if GameManager.has_item("The Last Pages"):
		if last_pages_texture:
			book_textures["The Last Pages"] = last_pages_texture
			missing_book_found = true

			if not current_order.has("The Last Pages"):
				var empty_index := current_order.find("")

				if empty_index != -1:
					current_order[empty_index] = "The Last Pages"
					GameManager.save_library_book_order(current_order)

	description_panel.hide()

	close_button.pressed.connect(close_puzzle)

	# Connect slot inputs.
	for i in range(slots.size()):
		var index := i

		slots[i].gui_input.connect(
			func(event: InputEvent):
				_on_slot_input(event, index)
		)

	update_books()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# ==================================================
# BOOK DISPLAY
# ==================================================

func update_books() -> void:
	for i in range(slots.size()):
		var image := slots[i].get_node(
			"TextureRect"
		) as TextureRect

		var book_name := current_order[i]

		if book_name == "":
			image.texture = null
			image.hide()
			continue

		if book_textures.has(book_name):
			image.texture = book_textures[book_name]
			image.show()
		else:
			image.texture = null
			image.hide()


# ==================================================
# SLOT INPUT
# ==================================================

func _on_slot_input(
	event: InputEvent,
	slot_index: int
) -> void:
	if yearbook_inspection != null:
		return

	if not event is InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if not event.pressed:
		return

	var book_name := current_order[slot_index]

	if book_name == "":
		return

	# Once solved, only Yearbook is interactive.
	if is_solved:
		if book_name == "Yearbook":
			open_yearbook_inspection()
		return

	start_drag(slot_index)


# ==================================================
# DRAGGING
# ==================================================

func start_drag(slot_index: int) -> void:
	if dragging_from != -1:
		return

	var book_name := current_order[slot_index]

	if book_name == "":
		return

	if not book_textures.has(book_name):
		return

	dragging_from = slot_index
	dragging_book = book_name

	show_book_description(book_name)

	drag_preview = TextureRect.new()
	drag_preview.texture = book_textures[book_name]

	drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	drag_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_preview.top_level = true
	drag_preview.z_index = 100

	var source_image := slots[slot_index].get_node(
		"TextureRect"
	) as TextureRect

	drag_preview.size = source_image.size

	add_child(drag_preview)

	drag_preview.global_position = (
		get_global_mouse_position()
		- drag_preview.size / 2.0
	)

	source_image.modulate.a = 0.3


func _process(_delta: float) -> void:
	if drag_preview != null:
		drag_preview.global_position = (
			get_global_mouse_position()
			- drag_preview.size / 2.0
		)


func _input(event: InputEvent) -> void:
	if dragging_from == -1:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				finish_drag()


func finish_drag() -> void:
	if dragging_from == -1:
		return

	var target_index := get_slot_under_mouse()

	if target_index != -1:
		swap_books(dragging_from, target_index)

	var source_image := slots[dragging_from].get_node(
		"TextureRect"
	) as TextureRect

	source_image.modulate.a = 1.0

	if drag_preview != null:
		drag_preview.queue_free()
		drag_preview = null

	dragging_from = -1
	dragging_book = ""


func get_slot_under_mouse() -> int:
	var mouse_pos := get_global_mouse_position()

	for i in range(slots.size()):
		if slots[i].get_global_rect().has_point(mouse_pos):
			return i

	return -1


func swap_books(from_index: int, to_index: int) -> void:
	if from_index == to_index or is_solved:
		return

	var temporary := current_order[from_index]

	current_order[from_index] = current_order[to_index]
	current_order[to_index] = temporary

	GameManager.save_library_book_order(current_order)

	update_books()
	check_order()


# ==================================================
# BOOK DESCRIPTIONS
# ==================================================

func show_book_description(book_name: String) -> void:
	if not BOOK_DESCRIPTIONS.has(book_name):
		return

	description_label.text = (
		book_name + "\n\n"
		+ BOOK_DESCRIPTIONS[book_name]
	)

	description_panel.show()


# ==================================================
# ORDER VALIDATION
# ==================================================

func check_order() -> void:
	if not missing_book_found or is_solved:
		return

	if current_order == CORRECT_ORDER:
		solve_puzzle()


func solve_puzzle() -> void:
	if is_solved:
		return

	is_solved = true

	GameManager.set_library_books_arranged()
	GameManager.save_library_book_order(current_order)

	description_label.text = (
		"The books are finally in their rightful order.\n\n"
		+ "The 1974 Yearbook shifts forward slightly.\n"
		+ "Click the Yearbook to inspect it."
	)

	description_panel.show()

	puzzle_solved.emit()

	print("LIBRARY BOOKSHELF SOLVED!")


# ==================================================
# MISSING BOOK
# ==================================================

func add_missing_book(texture: Texture2D) -> void:
	if texture == null:
		return

	book_textures["The Last Pages"] = texture
	missing_book_found = true

	if current_order.has("The Last Pages"):
		return

	var empty_index := current_order.find("")

	if empty_index != -1:
		current_order[empty_index] = "The Last Pages"
		GameManager.save_library_book_order(current_order)

	update_books()
	check_order()


# ==================================================
# YEARBOOK INSPECTION
# ==================================================

func open_yearbook_inspection() -> void:
	if yearbook_inspection != null:
		return

	if yearbook_inspect_scene == null:
		push_error("YearbookInspect scene is not assigned!")
		return

	yearbook_inspection = yearbook_inspect_scene.instantiate() as Control

	if yearbook_inspection == null:
		push_error("YearbookInspect root must be Control!")
		return

	# Display inspection above bookshelf.
	add_child(yearbook_inspection)

	yearbook_inspection.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	yearbook_inspection.inspection_closed.connect(
		_on_yearbook_inspection_closed
	)

	GameManager.library_yearbook_inspected = true

	print("YEARBOOK INSPECTION OPENED")


func _on_yearbook_inspection_closed() -> void:
	yearbook_inspection = null

	if GameManager.has_item("Master Key"):
		description_label.text = (
			"The hidden compartment is empty.\n"
			+ "You have obtained the Master Key."
		)
		description_panel.show()


# ==================================================
# CLOSE BOOKSHELF
# ==================================================

func close_puzzle() -> void:
	if yearbook_inspection != null:
		return

	if drag_preview != null:
		drag_preview.queue_free()
		drag_preview = null

	dragging_from = -1
	dragging_book = ""

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	puzzle_closed.emit()
	hide()
