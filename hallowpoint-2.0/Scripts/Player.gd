extends CharacterBody2D


@export var speed := 200.0

# Texture variables for movement states
var idle_tex: Texture2D
var left_tex: Texture2D
var right_tex: Texture2D

func _ready() -> void:
	if GameManager.selected_character == "boy":
		idle_tex = preload("res://Assets/Images/CHARACTERS/BOY.png")
		left_tex = preload("res://Assets/Images/CHARACTERS/BOY-left.png")
		right_tex = preload("res://Assets/Images/CHARACTERS/BOY-right.png")
	
	elif GameManager.selected_character == "girl":
		idle_tex = preload("res://Assets/Images/CHARACTERS/GIRL.png")
		left_tex = preload("res://Assets/Images/CHARACTERS/GILR-left.png")
		right_tex = preload("res://Assets/Images/CHARACTERS/GIRL-right.png")
	
	$Sprite2D.texture = idle_tex

func _physics_process(delta):
	var direction = Vector2.ZERO

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
	
	# Update sprite texture according to horizontal movement
	if direction.x < 0:
		$Sprite2D.texture = left_tex
	elif direction.x > 0:
		$Sprite2D.texture = right_tex
	else:
		$Sprite2D.texture = idle_tex
