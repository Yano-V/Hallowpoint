
extends Area2D

@export var statue_name: String = "Statue"
@export_multiline var dialogue: String = ""
@export var statue_view: Texture2D

@export var is_rizal_statue: bool = false

var player_nearby: bool = false
var player: Node2D

@onready var prompt: Label = $InteractPrompt


func _ready() -> void:
	prompt.hide()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	print("StatueInteraction is ready: ", statue_name)


func _input(event: InputEvent) -> void:
	if not player_nearby:
		return

	if not event.is_action_pressed("interact"):
		return

	if event.is_echo():
		return

	var inspect_ui = get_tree().get_first_node_in_group(
		"StatueInspectUI"
	)

	if inspect_ui == null:
		print("ERROR: StatueInspectUI not found!")
		return

	if inspect_ui.visible:
		return

	var dialogue_ui = get_tree().get_first_node_in_group(
		"dialogue_ui"
	)

	if dialogue_ui != null and dialogue_ui.dialogue_active:
		return

	if player == null:
		return

	get_viewport().set_input_as_handled()

	prompt.hide()

	inspect_ui.show_statue(
		statue_name,
		dialogue,
		statue_view,
		player,
		is_rizal_statue
	)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_nearby = true
		prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player_nearby = false
		player = null
		prompt.hide()
