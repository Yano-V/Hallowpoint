extends CharacterBody2D

@export var speed: float = 300.0

var boy_texture = preload("res://Assets/Images/CHARACTERS/BOY.png")
var girl_texture = preload("res://Assets/Images/CHARACTERS/GIRL.png")

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	# Ensure physics and inputs are active when spawned
	get_tree().paused = false
	get_viewport().gui_release_focus()
	
	# Apply chosen character sprite
	apply_character_texture()

func apply_character_texture() -> void:
	if GameManager.selected_character == "boy":
		sprite_2d.texture = boy_texture
	elif GameManager.selected_character == "girl":
		sprite_2d.texture = girl_texture

func _physics_process(_delta: float) -> void:
	# Check directional keys (WASD & Arrow Keys)
	var input_direction := Vector2.ZERO
	
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_direction.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_direction.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_direction.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_direction.y += 1

	velocity = input_direction.normalized() * speed

	# Horizontal flip on left/right movement
	if input_direction.x < 0:
		sprite_2d.flip_h = true
	elif input_direction.x > 0:
		sprite_2d.flip_h = false

	move_and_slide()
