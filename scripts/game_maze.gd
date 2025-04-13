extends Control
@onready var maze_node: Node2D = $Maze
@onready var back_to_main_menucolor_rect: ColorRect = $BackToMainMenu/ColorRect
@onready var back_to_main_menu: CenterContainer = $BackToMainMenu
@onready var back_to_main_menu_no_button: AnimatedButton = $BackToMainMenu/VBoxContainer/HBoxContainer/No
@onready var back_to_main_menu_yes_button: AnimatedButton = $BackToMainMenu/VBoxContainer/HBoxContainer/Yes
@onready var floor_layer: TileMapLayer = $Maze/FloorLayer
@onready var wall_layer: TileMapLayer = $Maze/WallLayer
@onready var food_layer: TileMapLayer = $Maze/FoodLayer
@onready var ghost_blinky: GhostBlinky = $Maze/GhostBlinky
@onready var ghost_clyde: GhostClyde = $Maze/GhostClyde
@onready var ghost_inky: GhostInky = $Maze/GhostInky
@onready var ghost_pinky: GhostPinky = $Maze/GhostPinky
@onready var game_control_ap: AudioStreamPlayer = $GameControlAP
@onready var background_music_ap: AudioStreamPlayer = $BackgroundMusicAP
@onready var frightened_timer: Timer = $FrightenedTimer
@onready var chase_timer: Timer = $ChaseTimer
@onready var scatter_timer: Timer = $ScatterTimer
@onready var sfx_power_dot_eaten_ap: AudioStreamPlayer = $SFXPowerDotEatenAP
@onready var sfx_dot_eaten_ap: AudioStreamPlayer = $SFXDotEatenAP
@onready var sfx_ghost_eaten_ap: AudioStreamPlayer = $SFXGhostEatenAP
@onready var lives_label: Label = $GameRecordUI/VBoxContainer/Lives/LivesLabel
@onready var score_label: Label = $GameRecordUI/VBoxContainer/Score/ScoreLabel
@onready var pacman: BaseCharacter = $Maze/Pacman
@onready var sfx_pacman_caught_ap: AudioStreamPlayer = $SFXPacmanCaughtAP
@onready var hs_label: Label = $GameRecordUI/HighestScore/HSLabel
@onready var message_label: Label = $BackToMainMenu/VBoxContainer/MessageLabel

@onready var background: ColorRect = $Background

const MAIN_MENU_PATH = "res://scenes/main_menu.tscn"
const PACMAN = preload("res://scenes/pacman.tscn")
const GHOST_BLINKY = preload("res://scenes/ghost_blinky.tscn")
const GAME_START_COUNT_DOWN = preload("res://assets/sound_effects/game_start_count_down.mp3")
const GHOST_EATEN = preload("res://assets/sound_effects/ghost_eaten.wav")
const PAUSE = preload("res://assets/sound_effects/pause.mp3")
const GAME_LOSE = preload("res://assets/sound_effects/game_lose.mp3")
const GAME_WIN = preload("res://assets/sound_effects/game_win.mp3")
const BGM_SPECIAL = preload("res://assets/sound_effects/bgm_special.wav")
const BGM_NORMAL = preload("res://assets/sound_effects/bgm_normal.wav")
#const FLOOR_TILE_INDEX = Vector2i(4,20)
const PATH_FLOOR_TILE_INDEX = Vector2i(1, 2)
const WALL_TILE_INDEX = Vector2i(1, 14)
const GHOST_SPAWN_BODER_TOP_TILE_INDEX = Vector2i(1, 4)
const GHOST_SPAWN_BODER_BOTTOM_TILE_INDEX = Vector2i(1, 6)
const GHOST_SPAWN_BODER_LEFT_TILE_INDEX = Vector2i(0, 5)
const GHOST_SPAWN_BODER_RIGHT_TILE_INDEX = Vector2i(2, 5)
const GHOST_SPAWN_BODER_TOP_LEFT_TILE_INDEX = Vector2i(0, 4)
const GHOST_SPAWN_BODER_TOP_RIGHT_TILE_INDEX = Vector2i(2, 4)
const GHOST_SPAWN_BODER_BOTTOM_LEFT_TILE_INDEX = Vector2i(0, 6)
const GHOST_SPAWN_BODER_BOTTOM_RIGHT_TILE_INDEX = Vector2i(2, 6)
const GHOST_SPAWN_FLOOR_TILE_INDEX = Vector2i(0, 3)

var game_started = false

func _ready() -> void:
	background.color = Color.BLACK
	hs_label.text = str(GameData.highest_score)
	_set_path_assist()
	back_to_main_menucolor_rect.color = GlobalVariables.main_menu_color
	SignalBus.score_changed.connect(func(score):
		score_label.text = str(score)
		)
	SignalBus.lives_remaining_changed.connect(func(lives):
		lives_label.text = str(lives)
		)
	SignalBus.dot_eaten.connect(_play_dot_eaten)
	SignalBus.ghost_eaten.connect(func():
		sfx_ghost_eaten_ap.play()
		)
	SignalBus.pacman_caught.connect(_on_pacman_caught)
	SignalBus.no_lives_remains.connect(_lose)
	SignalBus.dot_eaten_all.connect(_win)

	_create_maze()
	GameData.init_game_record()
	# 等待地图创建完成后，更新寻路
	ghost_blinky.update_pathfinding_grid()
	ghost_clyde.update_pathfinding_grid()
	ghost_inky.update_pathfinding_grid()
	ghost_pinky.update_pathfinding_grid()

	await _play_when_game_started()
		# 首先进入scatter模式
	scatter_timer.start()


	# frightened结束后，恢复chase
	frightened_timer.timeout.connect(func():
		background_music_ap.stream = BGM_NORMAL
		background_music_ap.play()
		GameData.consecutive_kills_cnt = 0

		ghost_blinky.change_to_action_state()
		ghost_clyde.change_to_action_state()
		ghost_inky.change_to_action_state()
		ghost_pinky.change_to_action_state()
		)

	# chase 20秒后进入 scatter，以frightened优先
	chase_timer.timeout.connect(func():
		scatter_timer.start()
		GameData.now_ghost_action_mode = BaseGhost.States.Scatter
		if frightened_timer.is_stopped():
			ghost_blinky.change_to_action_state()
			ghost_clyde.change_to_action_state()
			ghost_inky.change_to_action_state()
			ghost_pinky.change_to_action_state()
		)

	# scatter 7秒后进入 chase，以frightened优先
	scatter_timer.timeout.connect(func():
		chase_timer.start()
		GameData.now_ghost_action_mode = BaseGhost.States.Chase
		if frightened_timer.is_stopped():
			ghost_blinky.change_to_action_state()
			ghost_clyde.change_to_action_state()
			ghost_inky.change_to_action_state()
			ghost_pinky.change_to_action_state()
		)


func _physics_process(_delta: float) -> void:
	if not frightened_timer.is_stopped():
		GameData.frightened_time_left = frightened_timer.time_left
	else:
		GameData.frightened_time_left = 0

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_pause"):
		if not game_started:
			return
		if not get_tree().paused:
			get_tree().paused = true
			back_to_main_menu.visible = true
			back_to_main_menu_no_button.grab_focus()
			background_music_ap.stop()
			game_control_ap.stream = PAUSE
			game_control_ap.play()
		else:
			get_tree().paused = false
			back_to_main_menu.visible = false
			game_control_ap.stream = PAUSE
			game_control_ap.play()
			background_music_ap.play()

func _set_path_assist():
	if SettingsManager.assist_mode_on:
		$Maze/BlinkyPathLine2D.visible = true
		$Maze/ClydePathLine2D.visible = true
		$Maze/InkyPathLine2D.visible = true
		$Maze/PinkyPathLine2D.visible = true
	else:
		$Maze/BlinkyPathLine2D.visible = false
		$Maze/ClydePathLine2D.visible = false
		$Maze/InkyPathLine2D.visible = false
		$Maze/PinkyPathLine2D.visible = false

func _create_maze():
	var generator = MazeGenerator.new(GameData._seed)
	var maze = generator.generate_maze_tiles()
	var dot_cnt = 0
	for x in MazeGenerator.MAZE_TILE_WIDTH:
		for y in MazeGenerator.MAZE_TILE_HEIGHT:
			var tile = MazeGenerator.get_maze_tile(maze, x, y)
			if MazeGenerator.Maze_tile.DOT == tile:
				dot_cnt += 1
				floor_layer.set_cell(Vector2i(x, y), 0, PATH_FLOOR_TILE_INDEX)
				food_layer.set_cell(Vector2i(x, y), 0, Vector2i.ZERO, 1)
			elif MazeGenerator.Maze_tile.POWER_DOT == tile:
				dot_cnt += 1
				floor_layer.set_cell(Vector2i(x, y), 0, PATH_FLOOR_TILE_INDEX)
				food_layer.set_cell(Vector2i(x, y), 0, Vector2i.ZERO, 2)
			elif MazeGenerator.Maze_tile.PACMAN_SPAWN == tile:
				floor_layer.set_cell(Vector2i(x, y), 0, PATH_FLOOR_TILE_INDEX)
			elif MazeGenerator.Maze_tile.WALL == tile:
				floor_layer.set_cell(Vector2i(x, y), 0, PATH_FLOOR_TILE_INDEX)
				wall_layer.set_cell(Vector2i(x, y), 0, WALL_TILE_INDEX)
			elif MazeGenerator.Maze_tile.GHOST_SPAWN_BODER == tile:
				floor_layer.set_cell(Vector2i(x, y), 0, GHOST_SPAWN_FLOOR_TILE_INDEX)
				# 默认数组都不越界
				var left_tile = MazeGenerator.get_maze_tile(maze, x -1, y)
				var right_tile = MazeGenerator.get_maze_tile(maze, x + 1, y)
				var top_tile = MazeGenerator.get_maze_tile(maze, x, y -1)
				var bottom_tile = MazeGenerator.get_maze_tile(maze, x, y + 1)
				# 上边界
				if MazeGenerator.Maze_tile.DOT == top_tile and MazeGenerator.Maze_tile.GHOST_SPAWN == bottom_tile:
					wall_layer.set_cell(Vector2i(x, y), 0, GHOST_SPAWN_BODER_TOP_TILE_INDEX)
				# 下边界
				if MazeGenerator.Maze_tile.DOT == bottom_tile and MazeGenerator.Maze_tile.GHOST_SPAWN == top_tile:
					wall_layer.set_cell(Vector2i(x, y), 0, GHOST_SPAWN_BODER_BOTTOM_TILE_INDEX)
				# 左边界
				if MazeGenerator.Maze_tile.DOT == left_tile and MazeGenerator.Maze_tile.GHOST_SPAWN == right_tile:
					wall_layer.set_cell(Vector2i(x, y), 0, GHOST_SPAWN_BODER_LEFT_TILE_INDEX)
				# 右边界
				if MazeGenerator.Maze_tile.DOT == right_tile and MazeGenerator.Maze_tile.GHOST_SPAWN == left_tile:
					wall_layer.set_cell(Vector2i(x, y), 0, GHOST_SPAWN_BODER_RIGHT_TILE_INDEX)
				# 左上边界
				if MazeGenerator.Maze_tile.GHOST_SPAWN_BODER == bottom_tile and MazeGenerator.Maze_tile.GHOST_SPAWN_BODER == right_tile:
					wall_layer.set_cell(Vector2i(x, y), 0, GHOST_SPAWN_BODER_TOP_LEFT_TILE_INDEX)
				# 右上边界
				if MazeGenerator.Maze_tile.GHOST_SPAWN_BODER == bottom_tile and MazeGenerator.Maze_tile.GHOST_SPAWN_BODER == left_tile:
					wall_layer.set_cell(Vector2i(x, y), 0, GHOST_SPAWN_BODER_TOP_RIGHT_TILE_INDEX)
				# 左下边界
				if MazeGenerator.Maze_tile.GHOST_SPAWN_BODER == top_tile and MazeGenerator.Maze_tile.GHOST_SPAWN_BODER == right_tile:
					wall_layer.set_cell(Vector2i(x, y), 0, GHOST_SPAWN_BODER_BOTTOM_LEFT_TILE_INDEX)
				# 右下边界
				if MazeGenerator.Maze_tile.GHOST_SPAWN_BODER == top_tile and MazeGenerator.Maze_tile.GHOST_SPAWN_BODER == left_tile:
					wall_layer.set_cell(Vector2i(x, y), 0, GHOST_SPAWN_BODER_BOTTOM_RIGHT_TILE_INDEX)

			elif MazeGenerator.Maze_tile.GHOST_SPAWN == tile:
				floor_layer.set_cell(Vector2i(x, y), 0, GHOST_SPAWN_FLOOR_TILE_INDEX)

	GameData.init_maze(maze, dot_cnt)

func _play_when_game_started():
	# 游戏开始音效
	game_started = false
	get_tree().paused = true
	game_control_ap.stream = GAME_START_COUNT_DOWN
	game_control_ap.play()
	await game_control_ap.finished
	get_tree().paused = false
	game_started = true
	# 切换为暂停音效
	game_control_ap.stream = PAUSE

	background_music_ap.play()

func _play_dot_eaten(dot):
	if "power_dot" == dot:
		sfx_power_dot_eaten_ap.play()

		background_music_ap.stream = BGM_SPECIAL
		background_music_ap.play()

		# 能量豆，全员进入frightened
		ghost_blinky.change_state(ghost_blinky.States.Frightened)
		ghost_clyde.change_state(ghost_clyde.States.Frightened)
		ghost_inky.change_state(ghost_inky.States.Frightened)
		ghost_pinky.change_state(ghost_pinky.States.Frightened)


		# 根据游戏状态设定时间
		var frightened_time = lerp(GlobalVariables.frightened_time_min, GlobalVariables.frightened_time_max, GameData.dot_cnt_left * 1.0 / GameData.dot_cnt_total * 1.0)
		frightened_timer.wait_time = frightened_time
		frightened_timer.start()
	else:
		sfx_dot_eaten_ap.play()

func _on_pacman_caught():
	sfx_pacman_caught_ap.play()
	if not GameData.lives_remaining >= 0:
		return
	_game_freeze_immediately()

	# 静止1秒，重置状态
	await get_tree().create_timer(1).timeout
	pacman.reset()
	ghost_blinky.reset()
	ghost_clyde.reset()
	ghost_inky.reset()
	ghost_pinky.reset()

	await _play_when_game_started()

	ghost_blinky.change_to_action_state()
	ghost_clyde.change_to_action_state()
	ghost_inky.change_to_action_state()
	ghost_pinky.change_to_action_state()
	scatter_timer.start()

func _game_freeze_immediately():
	# 鬼魂转为idle
	ghost_blinky.change_state(ghost_blinky.States.Idle)
	ghost_clyde.change_state(ghost_clyde.States.Idle)
	ghost_inky.change_state(ghost_inky.States.Idle)
	ghost_pinky.change_state(ghost_pinky.States.Idle)
	# pacman的速度为0
	pacman.speed = 0
	pacman.velocity = Vector2i.ZERO
	# 系统组件暂停
	background_music_ap.stop()
	frightened_timer.stop()
	chase_timer.stop()
	scatter_timer.stop()

func _win():
	_game_freeze_immediately()
	game_control_ap.stream = GAME_WIN
	game_control_ap.play()
	# 禁用退出菜单，转为强制显示
	get_tree().paused = true
	message_label.visible = true
	message_label.text = "Win!"
	game_started = false
	back_to_main_menu_no_button.disabled = true
	back_to_main_menu.visible = true

	back_to_main_menu_yes_button.grab_focus()

func _lose():
	_game_freeze_immediately()
	game_control_ap.stream = GAME_LOSE
	game_control_ap.play()
	# 禁用退出菜单，转为强制显示
	get_tree().paused = true
	message_label.visible = true
	message_label.text = "Lose..."
	game_started = false
	back_to_main_menu_no_button.disabled = true
	back_to_main_menu.visible = true

	back_to_main_menu_yes_button.grab_focus()

func _on_no_button_pressed() -> void:
	back_to_main_menu.hide()
	get_tree().paused = false
	game_control_ap.play()
	background_music_ap.play()

func _on_yes_button_pressed() -> void:
	SettingsManager.save_highest_score()
	get_tree().paused = false

	LoadManager.load_scene(MAIN_MENU_PATH)
