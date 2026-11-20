
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var ui = $UI
@onready var tutorial = $TutorialIG
@onready var location_indicator = $UI/LocationIndicator

var inventory: Array[String] = []


# ==================================================
# STAGE CONFIGURATION
# ==================================================

const MAP_STAGES: Dictionary = {
	# GARDEN
	"TYK": "Garden",
	"TYK2": "Garden",

	# SFC
	"TUNNEL1": "SFC",
	"SFCLobby": "SFC",
	"SFC2ndFloor": "SFC",
	"BookStore": "SFC",

	# LIBRARY
	"LBLobby": "Library",
	"LBFloors": "Library",
	"LBFloors2": "Library",
	"LBFloors3": "Library",
	"LBFloors4": "Library"
}


const STAGE_STARTS: Dictionary = {
	"Garden": {
		"map": "res://Scenes/TYK.tscn",
		"spawn": "PlayerSpawn"
	},

	"SFC": {
		"map": "res://Scenes/SFCLobby.tscn",
		"spawn": "PlayerSpawn"
	},

	"Library": {
		"map": "res://Scenes/LBLobby.tscn",
		"spawn": "PlayerSpawn"
	}
}


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	# Display initial location and stage.
	var initial_map := get_node_or_null("MapContainer/TYK")

	if initial_map == null:
		initial_map = get_node_or_null("TYK")

	if initial_map != null:
		location_indicator.update_location(initial_map.name)
		update_current_stage(initial_map.name)

	if GameState.return_to_pause:
		$UI/Pause.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		GameState.return_to_pause = false


# ==================================================
# STAGE TRACKING
# ==================================================

func update_current_stage(map_name: String) -> void:
	if not MAP_STAGES.has(map_name):
		push_warning("No stage assigned to map: " + map_name)
		return

	var stage_name: String = MAP_STAGES[map_name]

	if not STAGE_STARTS.has(stage_name):
		push_warning("No starting map configured for: " + stage_name)
		return

	var stage_data: Dictionary = STAGE_STARTS[stage_name]

	if GameState.current_stage == stage_name \
	and GameState.stage_start_map == stage_data["map"] \
	and GameState.stage_start_spawn == stage_data["spawn"]:
		return

	GameState.set_current_stage(
		stage_name,
		stage_data["map"],
		stage_data["spawn"]
	)

	print("CURRENT STAGE: ", stage_name)


# ==================================================
# PAUSE SYSTEM
# ==================================================

func _on_pause_btn_pressed() -> void:
	$UI/Pause.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


# ==================================================
# MAP TRANSITIONS
# ==================================================

func change_map(
	map_path: String,
	spawn_name: String = "PlayerSpawn"
) -> void:
	call_deferred(
		"_change_map_deferred",
		map_path,
		spawn_name
	)


func _change_map_deferred(
	map_path: String,
	spawn_name: String
) -> void:
	var map_resource := load(map_path) as PackedScene

	if map_resource == null:
		push_error("Could not load map: " + map_path)
		return

	var new_map := map_resource.instantiate()
	new_map.name = map_resource.resource_path.get_file().get_basename()

	# Remove current map, preserve Player, UI and TutorialG.
	for child in get_children():
		if child != player and child != ui and child != tutorial:
			remove_child(child)
			child.queue_free()

	add_child(new_map)

	# Find spawn marker.
	var spawn := new_map.find_child(
		spawn_name,
		true,
		false
	) as Marker2D

	if spawn == null:
		push_error(
			"Spawn marker '%s' not found in map '%s'."
			% [spawn_name, map_path]
		)
		return

	print("Destination map: ", new_map.name)
	print("Requested spawn: ", spawn_name)
	print("Found marker: ", spawn.get_path())
	print("Marker global position: ", spawn.global_position)

	# Move persistent player.
	player.global_position = spawn.global_position
	player.velocity = Vector2.ZERO

	# Update location indicator.
	location_indicator.update_location(new_map.name)

	# Update stage tracking.
	update_current_stage(new_map.name)

	# Prevent immediate MapExit retriggering.
	await _disable_map_exits_temporarily()


# ==================================================
# MAP EXIT PROTECTION
# ==================================================

func _disable_map_exits_temporarily() -> void:
	var exits := get_tree().get_nodes_in_group("map_exits")

	for exit in exits:
		if is_instance_valid(exit):
			exit.set_deferred("monitoring", false)

	await get_tree().create_timer(0.5).timeout

	for exit in get_tree().get_nodes_in_group("map_exits"):
		if is_instance_valid(exit):
			exit.set_deferred("monitoring", true)


# ==================================================
# RESTART CURRENT STAGE
# ==================================================


func restart_current_stage() -> void:
	var start_map: String = GameState.stage_start_map
	var start_spawn: String = GameState.stage_start_spawn

	print(
		"RESTARTING CURRENT STAGE: ",
		GameState.current_stage
	)

	# Reset the inspection interface.
	var item_inspect = get_tree().get_first_node_in_group(
		"item_inspect_ui"
	)

	if item_inspect != null:
		if item_inspect.has_method("reset_inspection"):
			item_inspect.reset_inspection()

	# Return to the beginning of the stage.
	change_map(start_map, start_spawn)



# ==================================================
# KEYBOARD PAUSE
# ==================================================

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_P:
				if not get_tree().paused:
					$UI/Pause.show()

					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
					get_tree().paused = true

					get_viewport().set_input_as_handled()
