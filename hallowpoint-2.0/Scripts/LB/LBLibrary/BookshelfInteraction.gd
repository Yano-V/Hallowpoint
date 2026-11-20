
extends Area2D

@export_file("*.tscn") var puzzle_scene_path: String

@onready var prompt: Label = $Prompt

var player_nearby: bool = false
var puzzle_open: bool = false

var player: CharacterBody2D = null
var puzzle_instance: Control = null
var puzzle_canvas: CanvasLayer = null


func _ready() -> void:
	prompt.hide()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		player = body as CharacterBody2D

		if not puzzle_open:
			prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player_nearby = false
		prompt.hide()


func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby or puzzle_open:
		return

	if event is InputEventKey:
		if event.keycode == KEY_E and event.pressed and not event.echo:
			open_puzzle()
			get_viewport().set_input_as_handled()


func open_puzzle() -> void:
	if puzzle_open:
		return

	if puzzle_scene_path.is_empty():
		push_error("Bookshelf Puzzle scene path is empty!")
		return

	var puzzle_resource := load(puzzle_scene_path) as PackedScene

	if puzzle_resource == null:
		push_error("Could not load BookshelfPuzzle.tscn!")
		return

	puzzle_instance = puzzle_resource.instantiate() as Control

	if puzzle_instance == null:
		push_error("BookshelfPuzzle root must be Control!")
		return

	puzzle_open = true
	prompt.hide()

	# Disable player movement
	if is_instance_valid(player):
		player.set_movement_enabled(false)

	# Create UI overlay
	puzzle_canvas = CanvasLayer.new()
	puzzle_canvas.name = "BookshelfCanvas"
	puzzle_canvas.layer = 10

	get_tree().current_scene.add_child(puzzle_canvas)
	puzzle_canvas.add_child(puzzle_instance)

	# Show cursor for puzzle interaction
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Connect puzzle close signal
	puzzle_instance.puzzle_closed.connect(close_puzzle)

	print("BOOKSHELF PUZZLE OPENED")


func close_puzzle() -> void:
	if not puzzle_open:
		return

	puzzle_open = false

	# Restore player movement
	if is_instance_valid(player):
		player.set_movement_enabled(true)

	# Remove puzzle UI
	if is_instance_valid(puzzle_canvas):
		puzzle_canvas.queue_free()

	puzzle_instance = null
	puzzle_canvas = null

	# Hide cursor again
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	# Show interaction prompt if player is still nearby
	if player_nearby:
		prompt.show()

	print("BOOKSHELF PUZZLE CLOSED")
