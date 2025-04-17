extends Node

# 定义设置键名常量
const SETTINGS_FILE = "user://settings.cfg"

var config = ConfigFile.new()

var assist_mode_on: bool

func _ready():
	# 加载设置
	load_settings()


# 加载所有设置
func load_settings():
	var err = config.load(SETTINGS_FILE)

	if err == OK:  # 文件加载成功
		# 语言设置
		var saved_lang = config.get_value("settings", "language", "zh")
		# 加载全屏设置
		var is_fullscreen = config.get_value("display", "fullscreen", false)
		# 加载音量设置
		var master_volume = config.get_value("audio", "master_volume", 0.5)
		var music_volume = config.get_value("audio", "music_volume", 0.5)
		var sfx_volume = config.get_value("audio", "sfx_volume", 0.5)
		# 加载最高分
		var highest_score = config.get_value("data", "highest_score", 0)
		GameData.highest_score = highest_score
		# 加载辅助模式
		assist_mode_on = config.get_value("game_play", "assist_mode", false)

		_set_language_preference(saved_lang)
		_set_fullscreen(is_fullscreen)
		_set_volume("Master", master_volume)
		_set_volume("Music", music_volume)
		_set_volume("SFX", sfx_volume)
	else:
		# 文件不存在，使用默认设置
		set_and_save_language_preference(OS.get_locale())
		set_and_save_volume("Master", 0.5)  # 默认主音量
		set_and_save_volume("Music", 0.5)  # 默认音乐音量
		set_and_save_volume("SFX", 0.5)  # 默认音效音量
		set_and_save_fullscreen_setting(false)  # 默认窗口模式
		GameData.highest_score = 0
		assist_mode_on = false

func save_assist_mode():
	config.set_value("game_play", "assist_mode", assist_mode_on)
	_save_settings()

func save_highest_score():
	if GameData.score > GameData.highest_score:
		config.set_value("data", "highest_score", GameData.score)
	_save_settings()

# 保存全屏设置
func set_and_save_language_preference(lang_code: String):
	_set_language_preference(lang_code)

	config.set_value("settings", "language", lang_code)
	_save_settings()

# 保存全屏设置
func set_and_save_fullscreen_setting(is_fullscreen: bool):
	_set_fullscreen(is_fullscreen)

	config.set_value("display", "fullscreen", is_fullscreen)
	_save_settings()

# 保存主音量设置
func set_and_save_volume(bus_name: StringName, volumn: float):
	_set_volume(bus_name, volumn)
	if bus_name == "Master":
		config.set_value("audio", "master_volume", volumn)
	elif "Music" == bus_name:
		config.set_value("audio", "music_volume", volumn)
	elif "SFX" == bus_name:
		config.set_value("audio", "sfx_volume", volumn)
	_save_settings()

func _set_language_preference(lang_code: String):
	TranslationServer.set_locale(lang_code)

func _set_fullscreen(_is_fullscreen: bool):
	var mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if _is_fullscreen else DisplayServer.WINDOW_MODE_MAXIMIZED
	DisplayServer.window_set_mode(mode)


func _set_volume(bus_name: StringName, volumn: float):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volumn))

func _save_settings():
	config.save(SETTINGS_FILE)
