extends Control
@onready var main_buttons_container: VBoxContainer = $CenterContainer/MainButtons
@onready var settings_menu_container: VBoxContainer = $CenterContainer/SettingsMenu
@onready var credits_menu_container: VBoxContainer = $CenterContainer/CreditsMenu
@onready var fullscreen_check_box: CheckBox = $CenterContainer/SettingsMenu/Fullscreen
@onready var main_vol_slider: HSlider = $CenterContainer/SettingsMenu/MainVolSlider
@onready var music_vol_slider: HSlider = $CenterContainer/SettingsMenu/MusicVolSlider
@onready var sfx_vol_slider: HSlider = $CenterContainer/SettingsMenu/SFXVolSlider
@onready var play_button: AnimatedButton = $CenterContainer/MainButtons/Play
@onready var settings_button: AnimatedButton = $CenterContainer/MainButtons/Settings
@onready var credits_button: AnimatedButton = $CenterContainer/MainButtons/Credits
@onready var settings_menu_back_button: AnimatedButton = $CenterContainer/SettingsMenu/Back
@onready var credits_menu_back_button: AnimatedButton = $CenterContainer/CreditsMenu/Back
@onready var background: ColorRect = $Background
@onready var assist_mode_check_box: CheckBox = $CenterContainer/SettingsMenu/AssistMode
@onready var seed_line_edit: LineEdit = $HBoxContainer/SeedLineEdit

const GAME_MAP_PATH = "res://scenes/game_maze.tscn"
func _ready() -> void:
	background.color = GlobalVariables.main_menu_color
	SettingsManager.load_settings()
	play_button.grab_focus()
	fullscreen_check_box.set_pressed_no_signal(true if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN else false)
	main_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	music_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	sfx_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	assist_mode_check_box.set_pressed_no_signal(SettingsManager.assist_mode_on)

func _on_play_button_pressed() -> void:
	if seed_line_edit.text:
		GameData._seed = seed_line_edit.text
	else:
		var timestamp_seconds = Time.get_unix_time_from_system()
		GameData._seed = str(timestamp_seconds)
	LoadManager.load_scene(GAME_MAP_PATH)

func _on_settings_button_pressed() -> void:
	main_buttons_container.hide()
	settings_menu_container.show()
	settings_menu_back_button.grab_focus()


func _on_credits_button_pressed() -> void:
	main_buttons_container.hide()
	credits_menu_container.show()
	credits_menu_back_button.grab_focus()


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_menu_back_pressed() -> void:
	main_buttons_container.show()
	if settings_menu_container.visible:
		settings_menu_container.hide()
		settings_button.grab_focus()
	if credits_menu_container.visible:
		credits_menu_container.hide()
		credits_button.grab_focus()



func _on_fullscreen_toggled(toggled_on: bool) -> void:
	SettingsManager.set_and_save_fullscreen_setting(toggled_on)


func _on_main_vol_slider_value_changed(value: float) -> void:
	SettingsManager.set_and_save_volume("Master", value)


func _on_music_vol_slider_value_changed(value: float) -> void:
	SettingsManager.set_and_save_volume("Music", value)


func _on_sfx_vol_slider_value_changed(value: float) -> void:
	SettingsManager.set_and_save_volume("SFX", value)


func _on_assist_mode_toggled(toggled_on: bool) -> void:
	SettingsManager.assist_mode_on = toggled_on
	SettingsManager.save_assist_mode()

func _on_seed_check_box_toggled(toggled_on: bool) -> void:
	seed_line_edit.visible = toggled_on
