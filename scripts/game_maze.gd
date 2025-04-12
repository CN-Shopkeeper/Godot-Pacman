extends Control
@onready var maze: Node2D = $Maze
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
@onready var game_start_ap: AudioStreamPlayer = $GameStartAP
@onready var background_music_ap: AudioStreamPlayer = $BackgroundMusicAP
@onready var sfxap: AudioStreamPlayer = $SFXAP
@onready var frightened_timer: Timer = $FrightenedTimer
@onready var chase_timer: Timer = $ChaseTimer
@onready var scatter_timer: Timer = $ScatterTimer

@onready var background: ColorRect = $Background

const MAIN_MENU_PATH = "res://scenes/main_menu.tscn"
const PACMAN = preload("res://scenes/pacman.tscn")
const GHOST_BLINKY = preload("res://scenes/ghost_blinky.tscn")
const DOT_EATEN = preload("res://assets/sound_effects/dot_eaten.wav")
const POWER_DOT_EATEN = preload("res://assets/sound_effects/power_dot_eaten.wav")
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
	back_to_main_menucolor_rect.color = GlobalVariables.main_menu_color
	_create_maze()
	# 等待地图创建完成后，更新寻路
	ghost_blinky.update_pathfinding_grid()
	ghost_clyde.update_pathfinding_grid()
	ghost_inky.update_pathfinding_grid()
	ghost_pinky.update_pathfinding_grid()

	# 游戏开始音效
	get_tree().paused = true
	game_start_ap.play()
	await game_start_ap.finished
	get_tree().paused = false
	game_started = true
	background_music_ap.play()
	# 首先进入scatter模式
	scatter_timer.start()

	SignalBus.dot_eaten.connect(_play_dot_eaten)

	# frightened结束后，恢复chase
	frightened_timer.timeout.connect(func():
		background_music_ap.stream = BGM_NORMAL
		background_music_ap.play()

		ghost_blinky.change_state(ghost_blinky.States.Chase)
		ghost_clyde.change_state(ghost_clyde.States.Chase)
		ghost_inky.change_state(ghost_inky.States.Chase)
		ghost_pinky.change_state(ghost_pinky.States.Chase)
		)

	# chase 20秒后进入 scatter，以frightened优先
	chase_timer.timeout.connect(func():
		scatter_timer.start()
		if frightened_timer.is_stopped():
			ghost_blinky.change_state(ghost_blinky.States.Scatter)
			ghost_clyde.change_state(ghost_clyde.States.Scatter)
			ghost_inky.change_state(ghost_inky.States.Scatter)
			ghost_pinky.change_state(ghost_pinky.States.Scatter)
		)

	# scatter 7秒后进入 chase，以frightened优先
	scatter_timer.timeout.connect(func():
		chase_timer.start()
		if frightened_timer.is_stopped():
			ghost_blinky.change_state(ghost_blinky.States.Chase)
			ghost_clyde.change_state(ghost_clyde.States.Chase)
			ghost_inky.change_state(ghost_inky.States.Chase)
			ghost_pinky.change_state(ghost_pinky.States.Chase)
		)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_pause"):
		if not game_started:
			return
		get_tree().paused = !get_tree().paused
		back_to_main_menu.visible = !back_to_main_menu.visible
		if back_to_main_menu.visible:
			back_to_main_menu_no_button.grab_focus()

func _create_maze():
	var generator = MazeGenerator.new("cry")
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

func _play_dot_eaten(dot):
	if "power_dot" == dot:
		sfxap.stream = POWER_DOT_EATEN
		sfxap.play()

		background_music_ap.stream = BGM_SPECIAL
		background_music_ap.play()

		# 能量豆，全员进入frightened
		ghost_blinky.change_state(ghost_blinky.States.Frightened)
		ghost_clyde.change_state(ghost_clyde.States.Frightened)
		ghost_inky.change_state(ghost_inky.States.Frightened)
		ghost_pinky.change_state(ghost_pinky.States.Frightened)

		# todo 根据游戏状态设定时间
		frightened_timer.wait_time = 10
		frightened_timer.start()
	else:
		sfxap.stream = DOT_EATEN
		sfxap.play()

func _on_no_button_pressed() -> void:
	back_to_main_menu.hide()
	get_tree().paused = false

func _on_yes_button_pressed() -> void:
	get_tree().paused = false
	IndieBlueprintSceneTransitioner.transition_to(
		MAIN_MENU_PATH,
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
				{
	"in": {
		"color": GlobalVariables.scene_transition_color,
		"duration": 1,
		"texture": IndieBlueprintPremadeTransitions.Squares
	},
	"out": {
		"color": GlobalVariables.scene_transition_color,
		"duration": 1,
		"texture": IndieBlueprintPremadeTransitions.Squares
	},
}
	)
