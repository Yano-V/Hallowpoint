
@tool
extends Area2D

@export var item_name: String = "Item"

@export var item_texture: Texture2D:
	set(value):
		item_texture = value

		if is_node_ready():
			sprite.texture = value
		else:
			var sprite_node = get_node_or_null("Sprite2D")
			if sprite_node:
				sprite_node.texture = value


# INSPECTION SETTINGS
@export var can_inspect: bool = false
@export var inspection_texture: Texture2D
@export_multiline var readable_text: String = ""


# OPTIONAL OPENING SEQUENCE
@export var can_open: bool = false
@export var opened_texture: Texture2D


# OPTIONAL ITEM INSIDE THE INSPECTED OBJECT
@export var contains_item: bool = false
@export var contained_item_name: String = "Magnifying Glass"
@export var contained_item_texture: Texture2D


@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt: Label = $Prompt


var player_nearby: bool = false
var collected: bool = false


func _ready() -> void:

	# EDITOR PREVIEW
	if Engine.is_editor_hint():
		if item_texture:
			sprite.texture = item_texture
		return

	# CHECK IF ITEM WAS ALREADY COLLECTED
	if GameManager.has_item(item_name):
		collected = true
		queue_free()
		return

	# APPLY ITEM TEXTURE
	if item_texture:
		sprite.texture = item_texture

	# INITIAL PROMPT
	prompt.text = "Press E to interact."
	prompt.hide()

	# CONNECT SIGNALS
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	print("PICKUP ITEM READY: ", item_name)


func _on_body_entered(body: Node2D) -> void:

	if body.is_in_group("player") and not collected:
		player_nearby = true
		prompt.show()


func _on_body_exited(body: Node2D) -> void:

	if body.is_in_group("player"):
		player_nearby = false
		prompt.hide()


func _unhandled_input(event: InputEvent) -> void:

	if not player_nearby or collected:
		return

	if event.is_action_pressed("interact") and not event.is_echo():
		pick_up_item()
		get_viewport().set_input_as_handled()


func pick_up_item() -> void:

	if collected:
		return

	collected = true

	# REGISTER ITEM IN INVENTORY
	GameManager.add_item(item_name)

	print("PICKED UP: ", item_name)

	prompt.hide()

	# FIND EXISTING DIALOGUE BOX
	var dialogue = get_tree().get_first_node_in_group(
		"dialogue_ui"
	)

	if dialogue:

		# CHOOSE A / AN
		var article := "a"

		var lower_name := item_name.to_lower()

		if lower_name.begins_with("a") \
		or lower_name.begins_with("e") \
		or lower_name.begins_with("i") \
		or lower_name.begins_with("o") \
		or lower_name.begins_with("u"):
			article = "an"

		# SHOW PICKUP MESSAGE
		dialogue.show_message(
			"You picked up " + article + " " + item_name + "."
		)

		# ENABLE ITEM INSPECTION
		if can_inspect and inspection_texture:

			dialogue.enable_inspection(
				inspection_texture,
				readable_text,
				can_open,
				opened_texture,
				contains_item,
				contained_item_name,
				contained_item_texture
			)

			print("INSPECTION ENABLED: ", item_name)

		else:
			print("INSPECTION NOT ENABLED: ", item_name)

	else:
		print("ERROR: DialogueBox not found!")

	# REMOVE PICKED-UP ITEM FROM MAP
	queue_free()
