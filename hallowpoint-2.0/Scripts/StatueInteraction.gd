
extends Area2D

@export var statue_name: String = "Statue"
@export_multiline var dialogue: String = ""
@export var statue_view: Texture2D

var player_nearby: bool = false
var player: Node2D

@onready var prompt: Label = $InteractPrompt


func _ready() -> void:
	prompt.hide()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	print("StatueInteraction is ready: ", statue_name)


func _input(event: InputEvent) -> void:
	if player_nearby and event.is_action_pressed("interact"):
		print("E KEY DETECTED: ", statue_name)

		if player == null:
			return

		var inspect_ui = get_tree().get_first_node_in_group(
			"StatueInspectUI"
		)

		if inspect_ui:
			get_viewport().set_input_as_handled()
			prompt.hide()

			inspect_ui.show_statue(
				statue_name,
				dialogue,
				statue_view,
				player
			)
		else:
			print("ERROR: StatueInspectUI not found!")


func _on_body_entered(body: Node2D) -> void:
	print("BODY ENTERED: ", body.name)

	if body.is_in_group("Player"):
		print("PLAYER DETECTED!")

		player = body
		player_nearby = true
		prompt.show()


func _on_body_exited(body: Node2D) -> void:
	print("BODY EXITED: ", body.name)

	if body == player:
		player_nearby = false
		player = null
		prompt.hide()
