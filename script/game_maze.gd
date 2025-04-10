extends Control
@onready var back_to_main_menucolor_rect: ColorRect = $BackToMainMenu/ColorRect
@onready var back_to_main_menu: CenterContainer = $BackToMainMenu
@onready var back_to_main_menu_no_button: AnimatedButton = $BackToMainMenu/VBoxContainer/HBoxContainer/No
@onready var back_to_main_menu_yes_button: AnimatedButton = $BackToMainMenu/VBoxContainer/HBoxContainer/Yes
@onready var floor_layer: TileMapLayer = $Maze/FloorLayer
@onready var wall_layer: TileMapLayer = $Maze/WallLayer
@onready var food_layer: TileMapLayer = $Maze/FoodLayer
@onready var ghost_blinky: CharacterBody2D = $Maze/GhostBlinky
@onready var ghost_clyde: CharacterBody2D = $Maze/GhostClyde
@onready var ghost_inky: CharacterBody2D = $Maze/GhostInky
@onready var ghost_pinky: CharacterBody2D = $Maze/GhostPinky

@onready var background: ColorRect = $Background

const MAIN_MENU_PATH = "res://scenes/main_menu.tscn"
const PACMAN = preload("res://scenes/pacman.tscn")
const GHOST_BLINKY = preload("res://scenes/ghost_blinky.tscn")
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

func _ready() -> void:
	background.color = Color.BLACK
	back_to_main_menucolor_rect.color = GlobalVariables.main_menu_color
	_create_maze()
	# 等待地图创建完成后，更新寻路
	ghost_blinky.update_pathfinding_grid()
	ghost_clyde.update_pathfinding_grid()
	ghost_inky.update_pathfinding_grid()
	ghost_pinky.update_pathfinding_grid()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_pause"):
		back_to_main_menu.visible = !back_to_main_menu.visible
		if back_to_main_menu.visible:
			back_to_main_menu_no_button.grab_focus()

func _create_maze():
	var generator = MazeGenerator.new("ldy")
	var maze = generator.generate_maze_tiles()
	GameData.maze = maze
	for x in MazeGenerator.MAZE_TILE_WIDTH:
		for y in MazeGenerator.MAZE_TILE_HEIGHT:
			var tile = MazeGenerator.get_maze_tile(maze, x, y)
			if MazeGenerator.Maze_tile.PATH == tile:
				floor_layer.set_cell(Vector2i(x, y), 0, PATH_FLOOR_TILE_INDEX)
				food_layer.set_cell(Vector2i(x, y), 0, Vector2i.ZERO, 1)
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
				if MazeGenerator.Maze_tile.PATH == top_tile and MazeGenerator.Maze_tile.GHOST_SPAWN == bottom_tile:
					wall_layer.set_cell(Vector2i(x, y), 0, GHOST_SPAWN_BODER_TOP_TILE_INDEX)
				# 下边界
				if MazeGenerator.Maze_tile.PATH == bottom_tile and MazeGenerator.Maze_tile.GHOST_SPAWN == top_tile:
					wall_layer.set_cell(Vector2i(x, y), 0, GHOST_SPAWN_BODER_BOTTOM_TILE_INDEX)
				# 左边界
				if MazeGenerator.Maze_tile.PATH == left_tile and MazeGenerator.Maze_tile.GHOST_SPAWN == right_tile:
					wall_layer.set_cell(Vector2i(x, y), 0, GHOST_SPAWN_BODER_LEFT_TILE_INDEX)
				# 右边界
				if MazeGenerator.Maze_tile.PATH == right_tile and MazeGenerator.Maze_tile.GHOST_SPAWN == left_tile:
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



func _on_no_button_pressed() -> void:
	back_to_main_menu.hide()

func _on_yes_button_pressed() -> void:
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
