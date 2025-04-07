extends Node2D

func _ready() -> void:
	var maze = MazeGenerator.new("1")
	var half_maze_cells = maze._generate_half_maze_cells()
	for y in maze.half_cell_height:
		var st = ""
		for x in maze.half_cell_width:
			st += str(half_maze_cells[x + y * maze.half_cell_width]) + " "
		print(st)
	maze.reset_seed("1")
	var paths = maze._generate_maze_paths()
	for y in maze.half_path_height:
		var st = ""
		for x in maze.half_path_width:
			st += str(paths[x + y * maze.half_path_width])
		print(st)

	maze.reset_seed("1")
	var tiles = maze.generate_maze_tiles()
	for y in maze.MAZE_TILE_HEIGHT:
		var st = ""
		for x in maze.MAZE_TILE_WIDTH:
			st += str(tiles[x + y * maze.MAZE_TILE_WIDTH])
		print(st)
