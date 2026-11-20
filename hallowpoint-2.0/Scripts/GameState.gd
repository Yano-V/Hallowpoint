
extends Node

var settings_return_to: String = ""
var return_to_pause: bool = false

# Persistent player inventory
var inventory: Array[String] = []

const SETTINGS_FILE = "user://settings.cfg"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Restore saved fullscreen preference on launch.
	var config := ConfigFile.new()

	if config.load(SETTINGS_FILE) == OK:
		var fullscreen_enabled: bool = config.get_value(
			"display", "fullscreen", false
		)

		set_fullscreen(fullscreen_enabled)


func is_fullscreen() -> bool:
	var mode := DisplayServer.window_get_mode()

	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN \
		or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN


func set_fullscreen(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
		)
	else:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED
		)


func toggle_fullscreen() -> void:
	set_fullscreen(not is_fullscreen())

	# Save the fullscreen preference.
	var config := ConfigFile.new()
	config.load(SETTINGS_FILE)

	config.set_value(
		"display", "fullscreen", is_fullscreen()
	)

	config.save(SETTINGS_FILE)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_F11:
			if event.pressed and not event.echo:
				toggle_fullscreen()
				get_viewport().set_input_as_handled()


var current_stage: String = "Garden"

var stage_start_map: String = "res://Scenes/TYK.tscn"
var stage_start_spawn: String = "PlayerSpawn"


func set_current_stage(
	stage_name: String,
	start_map: String,
	spawn_name: String = "PlayerSpawn"
) -> void:
	current_stage = stage_name
	stage_start_map = start_map
	stage_start_spawn = spawn_name
