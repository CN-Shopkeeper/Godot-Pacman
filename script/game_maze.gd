extends Control
@onready var back_to_main_menucolor_rect: ColorRect = $BackToMainMenu/ColorRect
@onready var back_to_main_menu: CenterContainer = $BackToMainMenu
@onready var back_to_main_menu_no_button: AnimatedButton = $BackToMainMenu/VBoxContainer/HBoxContainer/No
@onready var back_to_main_menu_yes_button: AnimatedButton = $BackToMainMenu/VBoxContainer/HBoxContainer/Yes
@onready var floor_layer: TileMapLayer = $Maze/TileLayer
@onready var background: ColorRect = $Background

const MAIN_MENU_PATH = "res://scenes/main_menu.tscn"

const FLOOR_TILE_INDEX = Vector2i(1, 5)
const WALL_TILE_INDEX = Vector2i(1, 14)

func _ready() -> void:
	background.color = Color.BLACK
	back_to_main_menucolor_rect.color = GlobalVariables.main_menu_color
	_create_maze()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_pause"):
		back_to_main_menu.visible = !back_to_main_menu.visible
		if back_to_main_menu.visible:
			back_to_main_menu_no_button.grab_focus()

func _create_maze():
	var generator = MazeGenerator.new("1")
	var maze = generator.generate_maze_tiles()
	for x in MazeGenerator.MAZE_TILE_WIDTH:
		for y in MazeGenerator.MAZE_TILE_HEIGHT:
			var atlas_coor = FLOOR_TILE_INDEX if MazeGenerator.Maze_tile.PATH == MazeGenerator.get_maze_tile(maze, x, y) else WALL_TILE_INDEX
			floor_layer.set_cell(Vector2i(x, y), 0, atlas_coor)

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
