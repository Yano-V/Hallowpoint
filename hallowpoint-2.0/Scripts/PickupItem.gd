@tool
extends Area2D

@export var item_name: String = "Item"
@export var item_texture: Texture2D:
	set(value):
		item_texture = value
		if sprite:
			sprite.texture = value

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt: Label = $Prompt

var player_nearby: bool = false
var collected: bool = false


func _ready() -> void:
	if item_texture:
		sprite.texture = item_texture
		
	prompt.text = "Press E to interact."
	prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	print("PICKUP ITEM READY: ", item_name)


func _on_body_entered(body: Node2D) -> void:
	print("BODY ENTERED: ", body.name)
	print("PLAYER GROUPS: ", body.get_groups())

	if body.is_in_group("player") and not collected:
		print("PLAYER DETECTED!")

		player_nearby = true
		prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	print("BODY EXITED: ", body.name)

	if body.is_in_group("player"):
		player_nearby = false
		prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and not collected:
		if event.is_action_pressed("interact"):
			pick_up_item()
			get_viewport().set_input_as_handled()


func pick_up_item() -> void:
	collected = true

	if not GameState.inventory.has(item_name):
		GameState.inventory.append(item_name)

	prompt.visible = false

	var dialogue = get_tree().get_first_node_in_group("dialogue_ui")

	if dialogue:
		var article := "an" if item_name.to_lower().begins_with(
			"a"
		) or item_name.to_lower().begins_with(
			"e"
		) or item_name.to_lower().begins_with(
			"i"
		) or item_name.to_lower().begins_with(
			"o"
		) or item_name.to_lower().begins_with(
			"u"
		) else "a"

		dialogue.show_message("You picked up " + article + " " + item_name + ".")
	else:
		print("ERROR: DialogueBox not found!")

	queue_free()
