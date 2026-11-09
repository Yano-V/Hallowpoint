
extends CanvasLayer

enum TutorialState {
	MOVEMENT_INSTRUCTION,
	WAIT_FOR_MOVEMENT,
	PAUSE_INSTRUCTION,
	WAIT_FOR_PAUSE,
	WAIT_FOR_RESUME,
	COMPLETED
}

var current_state = TutorialState.MOVEMENT_INSTRUCTION
var has_moved = false

var dialogue_tween: Tween

@onready var dialogue_panel = $DialoguePanel
@onready var dialogue_label = $DialoguePanel/DialogueLabel
@onready var continue_label = $DialoguePanel/ContinueLabel

@onready var pause_menu = $"../UI/Pause"


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Check if the player is returning to an already paused game.
	if GameState.return_to_pause:
		current_state = TutorialState.WAIT_FOR_RESUME
		dialogue_panel.hide()
		return
		
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	show_movement_instruction()


func _process(_delta):

	# Detect WASD movement.
	if current_state == TutorialState.WAIT_FOR_MOVEMENT:

		if (
			Input.is_key_pressed(KEY_W)
			or Input.is_key_pressed(KEY_A)
			or Input.is_key_pressed(KEY_S)
			or Input.is_key_pressed(KEY_D)
		):
			has_moved = true
			show_pause_instruction()

	# Detect when the player resumes the game.
	if current_state == TutorialState.WAIT_FOR_RESUME:

		if not get_tree().paused:
			finish_tutorial()


func _input(event):

	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	# E = Continue tutorial.
	if event.keycode == KEY_E:

		if current_state == TutorialState.MOVEMENT_INSTRUCTION:

			hide_dialogue_animation()

			current_state = TutorialState.WAIT_FOR_MOVEMENT

			get_viewport().set_input_as_handled()

		elif current_state == TutorialState.PAUSE_INSTRUCTION:

			hide_dialogue_animation()

			current_state = TutorialState.WAIT_FOR_PAUSE

			get_viewport().set_input_as_handled()


func show_movement_instruction():

	current_state = TutorialState.MOVEMENT_INSTRUCTION

	dialogue_label.text = "Press W, A, S, D to move around."
	continue_label.text = "Press E to continue."

	show_dialogue_animation()


func show_pause_instruction():

	current_state = TutorialState.PAUSE_INSTRUCTION

	dialogue_label.text = "Press P to pause the game."
	continue_label.text = "Press E to continue."

	show_dialogue_animation()


func open_pause_menu():

	current_state = TutorialState.WAIT_FOR_RESUME

	hide_dialogue_animation()

	pause_menu.show()

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	get_tree().paused = true


func finish_tutorial():

	current_state = TutorialState.COMPLETED

	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


# =====================================
# DIALOGUE FADE-IN AND POP-UP ANIMATION
# =====================================

func show_dialogue_animation():

	if dialogue_tween and dialogue_tween.is_running():
		dialogue_tween.kill()

	dialogue_panel.modulate.a = 0.0
	dialogue_panel.scale = Vector2(0.9, 0.9)

	dialogue_panel.pivot_offset = dialogue_panel.size / 2.0

	dialogue_panel.show()

	dialogue_tween = create_tween()
	dialogue_tween.set_parallel(true)

	# Fade in.
	dialogue_tween.tween_property(
		dialogue_panel,
		"modulate:a",
		1.0,
		0.3
	)

	# Pop-up effect.
	dialogue_tween.tween_property(
		dialogue_panel,
		"scale",
		Vector2(1.0, 1.0),
		0.3
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# =====================================
# DIALOGUE FADE-OUT ANIMATION
# =====================================

func hide_dialogue_animation():

	if dialogue_tween and dialogue_tween.is_running():
		dialogue_tween.kill()

	dialogue_tween = create_tween()
	dialogue_tween.set_parallel(true)

	# Fade out.
	dialogue_tween.tween_property(
		dialogue_panel,
		"modulate:a",
		0.0,
		0.2
	)

	# Slightly shrink.
	dialogue_tween.tween_property(
		dialogue_panel,
		"scale",
		Vector2(0.95, 0.95),
		0.2
	)

	# Hide after animation finishes.
	dialogue_tween.chain().tween_callback(
		dialogue_panel.hide
	)
