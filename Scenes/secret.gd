extends Area2D

@export var required_tool: String = ""       # Leave blank if no tool needed
@export var reward_item_name: String = ""    # e.g., "key" or "candle"
@export var reward_texture: Texture2D        # Drag your .png asset here in Inspector

@onready var interact_label: Label = $InteractLabel

var player_near := false
var puzzle_solved := false

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_near = true
		if interact_label and not puzzle_solved:
			interact_label.show()

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_near = false
		if interact_label:
			interact_label.hide()

func _process(delta: float) -> void:
	if player_near and not puzzle_solved:
		if Input.is_action_just_pressed("ui_accept") or Input.is_physical_key_pressed(KEY_SPACE):
			print("Space/Interact pressed near object!")
			
			if required_tool != "":
				if Global.inventory.has(required_tool):
					solve_puzzle()
				else:
					print("Missing required tool: " + required_tool)
					if interact_label:
						interact_label.text = "You need a " + required_tool + "!"
			else:
				solve_puzzle()

func solve_puzzle() -> void:
	puzzle_solved = true
	print("Puzzle solved successfully!")
	
	if interact_label:
		interact_label.hide()
		
	if reward_item_name != "" and not Global.inventory.has(reward_item_name):
		Global.inventory.append(reward_item_name)
		print("Added to Global inventory: " + reward_item_name)
		
	if reward_texture:
		var reward_sprite = Sprite2D.new()
		reward_sprite.texture = reward_texture
		reward_sprite.position = Vector2(0, -30) # Spawns slightly above the base
		add_child(reward_sprite)
