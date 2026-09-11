extends CharacterBody2D


@export var speed := 275.0

func _ready() -> void:
	if GameManager.selected_character == "boy":
		$Sprite2D.texture = preload("res://Assets/Images/BOY2.png")
	
	elif GameManager.selected_character == "girl":
		$Sprite2D.texture = preload("res://Assets/Images/GIRL2.png")

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
