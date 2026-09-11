extends Control

var return_to := "main_menu"

const SETTINGS_FILE = "user://settings.cfg"

@onready var master_slider = $SettingsPanel/SettingsList/MasterVolume/MasterSlider
@onready var music_slider = $SettingsPanel/SettingsList/MusicVolume/MusicSlider
@onready var sfx_slider = $SettingsPanel/SettingsList/SFXVolume/SFXSlider


func _ready() -> void:
	load_settings()


func load_settings() -> void:
	var config = ConfigFile.new()

	if config.load(SETTINGS_FILE) == OK:
		master_slider.value = config.get_value("volume", "master", 100.0)
		music_slider.value = config.get_value("volume", "music", 100.0)
		sfx_slider.value = config.get_value("volume", "sfx", 100.0)


func save_settings() -> void:
	var config = ConfigFile.new()

	config.set_value("volume", "master", master_slider.value)
	config.set_value("volume", "music", music_slider.value)
	config.set_value("volume", "sfx", sfx_slider.value)

	config.save(SETTINGS_FILE)


func _on_master_volume_changed(value: float) -> void:
	save_settings()


func _on_music_volume_changed(value: float) -> void:
	save_settings()


func _on_sfx_volume_changed(value: float) -> void:
	save_settings()


func _on_back_btn_pressed():
	if GameState.settings_return_to == "PAUSE":
		get_tree().change_scene_to_file("res://Scenes/Game.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/MENU.tscn")
