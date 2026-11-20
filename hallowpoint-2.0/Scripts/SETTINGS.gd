
extends Control

var return_to := "main_menu"

const SETTINGS_FILE = "user://settings.cfg"

# Volume sliders
@onready var master_slider = $SettingsPanel/SettingsList/MasterVolume/MasterSlider
@onready var music_slider = $SettingsPanel/SettingsList/MusicVolume/MusicSlider
@onready var sfx_slider = $SettingsPanel/SettingsList/SFXVolume/SFXSlider

# Fullscreen checkbox
@onready var fullscreen_checkbox: CheckBox = $SettingsPanel/SettingsList/Fullscreen


func _ready() -> void:
	# Connect fullscreen checkbox if not already connected.
	if not fullscreen_checkbox.toggled.is_connected(
		_on_fullscreen_toggled
	):
		fullscreen_checkbox.toggled.connect(
			_on_fullscreen_toggled
		)

	# Load saved settings.
	load_settings()


func _process(_delta: float) -> void:
	# Keep checkbox synchronized with F11 fullscreen changes.
	var fullscreen_enabled: bool = GameState.is_fullscreen()

	if fullscreen_checkbox.button_pressed != fullscreen_enabled:
		fullscreen_checkbox.set_pressed_no_signal(
			fullscreen_enabled
		)


func load_settings() -> void:
	var config := ConfigFile.new()

	if config.load(SETTINGS_FILE) == OK:
		# Load volume settings.
		master_slider.value = config.get_value(
			"volume", "master", 100.0
		)

		music_slider.value = config.get_value(
			"volume", "music", 100.0
		)

		sfx_slider.value = config.get_value(
			"volume", "sfx", 100.0
		)

		# Load fullscreen preference.
		var fullscreen_enabled: bool = config.get_value(
			"display", "fullscreen", false
		)

		fullscreen_checkbox.set_pressed_no_signal(
			fullscreen_enabled
		)

		GameState.set_fullscreen(fullscreen_enabled)

	else:
		# No saved settings yet.
		fullscreen_checkbox.set_pressed_no_signal(
			GameState.is_fullscreen()
		)


func save_settings() -> void:
	var config := ConfigFile.new()

	# Load existing file to preserve other settings.
	config.load(SETTINGS_FILE)

	# Save volume settings.
	config.set_value(
		"volume", "master", master_slider.value
	)

	config.set_value(
		"volume", "music", music_slider.value
	)

	config.set_value(
		"volume", "sfx", sfx_slider.value
	)

	# Save fullscreen preference.
	config.set_value(
		"display", "fullscreen",
		GameState.is_fullscreen()
	)

	var error := config.save(SETTINGS_FILE)

	if error != OK:
		push_warning("Failed to save settings.")


func _on_fullscreen_toggled(enabled: bool) -> void:
	# Apply fullscreen setting.
	GameState.set_fullscreen(enabled)

	# Save the new preference.
	save_settings()


func _on_master_volume_changed(_value: float) -> void:
	save_settings()


func _on_music_volume_changed(_value: float) -> void:
	save_settings()


func _on_sfx_volume_changed(_value: float) -> void:
	save_settings()


func _on_back_btn_pressed() -> void:
	if GameState.settings_return_to == "PAUSE":
		get_tree().change_scene_to_file(
			"res://Scenes/Game.tscn"
		)
	else:
		get_tree().change_scene_to_file(
			"res://Scenes/MENU.tscn"
		)
