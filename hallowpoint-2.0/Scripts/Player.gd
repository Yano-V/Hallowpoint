
extends CharacterBody2D

@export var speed: float = 200.0

# Character textures
var idle_tex: Texture2D
var left_tex: Texture2D
var right_tex: Texture2D

# Footstep surface tracking
var grass_overlaps: int = 0
var concrete_overlaps: int = 0
var current_surface: String = ""

@onready var grass_footstep: AudioStreamPlayer2D = $GrassFootstep
@onready var concrete_footstep: AudioStreamPlayer2D = $ConcreteFootstep
@onready var grass_step_timer: Timer = $GrassStepTimer
@onready var concrete_step_timer: Timer = $ConcreteStepTimer


func _ready() -> void:
	# Load the selected character's textures
	if GameManager.selected_character == "boy":
		idle_tex = preload("res://Assets/Images/CHARACTERS/BOY.png")
		left_tex = preload("res://Assets/Images/CHARACTERS/BOY-left.png")
		right_tex = preload("res://Assets/Images/CHARACTERS/BOY-right.png")

	elif GameManager.selected_character == "girl":
		idle_tex = preload("res://Assets/Images/CHARACTERS/GIRL.png")
		left_tex = preload("res://Assets/Images/CHARACTERS/GILR-left.png")
		right_tex = preload("res://Assets/Images/CHARACTERS/GIRL-right.png")

	$Sprite2D.texture = idle_tex

	# Connect the timers
	if not grass_step_timer.timeout.is_connected(_on_grass_step_timer_timeout):
		grass_step_timer.timeout.connect(_on_grass_step_timer_timeout)

	if not concrete_step_timer.timeout.is_connected(_on_concrete_step_timer_timeout):
		concrete_step_timer.timeout.connect(_on_concrete_step_timer_timeout)


func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO

	# WASD movement
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S):
		direction.y += 1
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_key_pressed(KEY_D):
		direction.x += 1

	direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()

	# Update character texture
	if direction.x < 0:
		$Sprite2D.texture = left_tex
	elif direction.x > 0:
		$Sprite2D.texture = right_tex
	else:
		$Sprite2D.texture = idle_tex

	# Handle footsteps
	if velocity.length() == 0:
		stop_footsteps()

	elif current_surface == "grass":
		concrete_footstep.stop()
		concrete_step_timer.stop()

		if grass_step_timer.is_stopped():
			grass_footstep.play()
			grass_step_timer.start()

	elif current_surface == "concrete":
		grass_footstep.stop()
		grass_step_timer.stop()

		if concrete_step_timer.is_stopped():
			concrete_footstep.play()
			concrete_step_timer.start()

	else:
		stop_footsteps()


func enter_footstep_surface(surface: String) -> void:
	if surface == "grass":
		grass_overlaps += 1
	elif surface == "concrete":
		concrete_overlaps += 1

	update_footstep_surface()


func exit_footstep_surface(surface: String) -> void:
	if surface == "grass":
		grass_overlaps = max(0, grass_overlaps - 1)
	elif surface == "concrete":
		concrete_overlaps = max(0, concrete_overlaps - 1)

	update_footstep_surface()


func update_footstep_surface() -> void:
	var new_surface: String = ""

	# Prefer concrete if both surfaces overlap
	if concrete_overlaps > 0:
		new_surface = "concrete"
	elif grass_overlaps > 0:
		new_surface = "grass"

	if current_surface != new_surface:
		current_surface = new_surface
		stop_footsteps()


func stop_footsteps() -> void:
	grass_footstep.stop()
	concrete_footstep.stop()
	grass_step_timer.stop()
	concrete_step_timer.stop()


func _on_grass_step_timer_timeout() -> void:
	if current_surface == "grass" and velocity.length() > 0:
		grass_footstep.play()
		grass_step_timer.start()


func _on_concrete_step_timer_timeout() -> void:
	if current_surface == "concrete" and velocity.length() > 0:
		concrete_footstep.play()
		concrete_step_timer.start()
