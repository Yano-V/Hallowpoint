
extends Node

var selected_character = ""
var player_name = ""

# ==================================================
# INVENTORY
# ==================================================

var inventory: Dictionary = {}

# Items belonging to each stage.
const STAGE_ITEMS: Dictionary = {
	"Garden": [
		"Golden Shard",
		"Shovel"
	],

	"SFC": [
		"History Book",
		"Book Receipt",
		"Magnifying Glass"
	],

	"Library": [
		"Master Key"
	]
}


# ==================================================
# RIZAL STATUE PUZZLE
# ==================================================

var rizal_first_inspected: bool = false
var rizal_stone_book_read: bool = false
var rizal_candle_placed: bool = false
var rizal_shard_collected: bool = false


# ==================================================
# LIBRARY BOOKSHELF PUZZLE
# ==================================================

const LIBRARY_STARTING_ORDER: Array[String] = [
	"Growth",
	"Yearbook",
	"Change",
	"Beginnings",
	"Foundations",
	""
]

var library_book_order: Array[String] = []

var library_books_arranged: bool = false

var library_yearbook_inspected: bool = false
var library_hidden_mark_found: bool = false
var library_master_key_collected: bool = false


func get_library_book_order() -> Array[String]:
	if library_book_order.is_empty():
		library_book_order = LIBRARY_STARTING_ORDER.duplicate()

	return library_book_order.duplicate()


func save_library_book_order(order: Array[String]) -> void:
	library_book_order = order.duplicate()

	print("LIBRARY BOOK ORDER SAVED: ", library_book_order)


func set_library_books_arranged() -> void:
	library_books_arranged = true

	print("LIBRARY BOOKSHELF SOLVED!")


# ==================================================
# INVENTORY FUNCTIONS
# ==================================================

func add_item(item_name: String) -> void:
	inventory[item_name] = true

	if not GameState.inventory.has(item_name):
		GameState.inventory.append(item_name)

	print("ITEM COLLECTED: ", item_name)


func has_item(item_name: String) -> bool:
	return inventory.get(item_name, false) \
		or GameState.inventory.has(item_name)


func remove_item(item_name: String) -> void:
	inventory.erase(item_name)
	GameState.inventory.erase(item_name)


# ==================================================
# STAGE RESTART SYSTEM
# ==================================================

func reset_stage(stage_name: String) -> void:
	print("RESTARTING STAGE: ", stage_name)

	# Remove only items belonging to this stage.
	if STAGE_ITEMS.has(stage_name):
		for item_name in STAGE_ITEMS[stage_name]:
			remove_item(item_name)
			print("REMOVED STAGE ITEM: ", item_name)

	# Reset puzzle progress for the current stage.
	match stage_name:
		"Garden":
			reset_garden_stage()

		"SFC":
			reset_sfc_stage()

		"Library":
			reset_library_stage()

		_:
			push_warning(
				"No reset configuration for stage: " + stage_name
			)


# ==================================================
# GARDEN STAGE RESET
# ==================================================

func reset_garden_stage() -> void:
	rizal_first_inspected = false
	rizal_stone_book_read = false
	rizal_candle_placed = false
	rizal_shard_collected = false

	print("GARDEN STAGE RESET!")


# ==================================================
# SFC STAGE RESET
# ==================================================

func reset_sfc_stage() -> void:
	# Add SFC-specific puzzle variables here
	# when they are implemented.

	print("SFC STAGE RESET!")
	
	print("GAME MANAGER INVENTORY: ", inventory)
	print("GAME STATE INVENTORY: ", GameState.inventory)

# ==================================================
# LIBRARY STAGE RESET
# ==================================================

func reset_library_stage() -> void:
	# Reset bookshelf puzzle.
	library_book_order = LIBRARY_STARTING_ORDER.duplicate()
	library_books_arranged = false

	# Reset Yearbook puzzle.
	library_yearbook_inspected = false
	library_hidden_mark_found = false
	library_master_key_collected = false

	print("LIBRARY STAGE RESET!")
