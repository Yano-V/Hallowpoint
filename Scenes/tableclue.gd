extends Area2D

@export var receipt_ui: TextureRect          # Drag your UI popup (e.g., ReceiptPopup) here
@export var required_tool: String = ""       # Required tool name (e.g. "magnifying_glass") or leave blank
@export var reward_item_name: String = ""    # Item name saved to Global.inventory (e.g. "key")
@export var reward_texture: Texture2D        # Visual sprite spawned on floor (e.g. key/candle texture)

@onready var interact_label: Label = $InteractLabel

var player_near := false
var puzzle_solved := false

func _ready() -> void:
	if interact_label:
		interact_label.hide()
		# Dynamically format the floating hint label
		if required_tool != "":
			interact_label.text = "Press [Enter] to use " + required_tool
		elif receipt_ui:
			interact_label.text = "Press [Enter] to read"
		else:
			interact_label.text = "Press [Enter] to interact"

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D: # Detects player regardless of node name
		player_near = true
		if interact_label and not puzzle_solved:
			interact_label.show()

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_near = false
		if interact_label:
			interact_label.hide()
		if receipt_ui:
			receipt_ui.hide()

func _process(delta: float) -> void:
	if player_near and Input.is_action_just_pressed("ui_accept"):
		# 1. Check tool gating requirement if specified
		if required_tool != "":
			if Global.inventory.has(required_tool):
				execute_interaction()
			else:
				if interact_label:
					interact_label.text = "You need a " + required_tool + "!"
		else:
			execute_interaction()

func execute_interaction() -> void:
	# 2. Toggle the UI pop-up (receipt / paper image) on or off
	if receipt_ui:
		receipt_ui.visible = !receipt_ui.visible

	# 3. Handle item rewards on first interaction
	if not puzzle_solved:
		puzzle_solved = true
		
		if interact_label and not receipt_ui:
			interact_label.hide()
			
		# Add reward item to the invisible global inventory
		if reward_item_name != "":
			if not Global.inventory.has(reward_item_name):
				Global.inventory.append(reward_item_name)
				print("Player obtained: " + reward_item_name)
				
		# Spawn visual reward sprite slightly above the object
		if reward_texture:
			var reward_sprite = Sprite2D.new()
			reward_sprite.texture = reward_texture
			reward_sprite.position = Vector2(0, -30)
			add_child(reward_sprite)
