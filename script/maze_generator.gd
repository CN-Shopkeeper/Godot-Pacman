class_name MazeGenerator
extends Resource

enum Maze_tile {WALL, PATH, GHOST_SPAWN, GHOST_SPAWN_BODER}

const half_cell_height = 9
const half_cell_width = 5
# 27
const half_path_height = half_cell_height * 3
# 15
const half_path_width = half_cell_width * 3
# 30
const MAZE_TILE_HEIGHT = half_path_height -1 + 4
# 32
const MAZE_TILE_WIDTH = (half_path_width -1 + 2) * 2
const GHOST_GATE_CELL_TOP = 3

var rng: RandomNumberGenerator

func _init(seed: String) -> void:
	rng = RandomNumberGenerator.new()
	rng.set_seed(seed.hash())

func reset_seed(seed: String):
	rng.set_seed(seed.hash())

# 一格cell对应三个tiles，详见参考算法

func generate_maze_tiles():
	var half_maze_paths = _generate_maze_paths()
	var maze_tiles: Array = []
	maze_tiles.resize(MAZE_TILE_HEIGHT * MAZE_TILE_WIDTH)
	maze_tiles.fill(-1)
	# 四周的墙
	for x in range(MAZE_TILE_WIDTH):
		_set_maze_tile(maze_tiles, x, 0, Maze_tile.WALL)
		_set_maze_tile(maze_tiles, x, MAZE_TILE_HEIGHT -1, Maze_tile.WALL)
	for y in range(MAZE_TILE_HEIGHT):
		_set_maze_tile(maze_tiles, 0, y, Maze_tile.WALL)
		_set_maze_tile(maze_tiles, MAZE_TILE_WIDTH -1, y, Maze_tile.WALL)

	# 第二圈的路
	for x in range(1, MAZE_TILE_WIDTH -1):
		_set_maze_tile(maze_tiles, x, 1, Maze_tile.PATH)
		_set_maze_tile(maze_tiles, x, MAZE_TILE_HEIGHT -2, Maze_tile.PATH)
	for y in range(1, MAZE_TILE_HEIGHT -1):
		_set_maze_tile(maze_tiles, 1, y, Maze_tile.PATH)
		_set_maze_tile(maze_tiles, MAZE_TILE_WIDTH -2, y, Maze_tile.PATH)

	# 复制half_paths的数据
	for x in range(half_path_width -1):
		for y in range(1, half_path_height):
			var tile = _get_half_maze_path(half_maze_paths, x, y)
			_set_maze_tile(maze_tiles, x + 2, y + 1, tile)
			# x方向对称
			_set_maze_tile(maze_tiles, MAZE_TILE_WIDTH -1-2- x, y + 1, tile)

	# Ghost出生区的墙壁
	for x in range(11, 21):
		_set_maze_tile(maze_tiles, x, 11, Maze_tile.GHOST_SPAWN_BODER)
		_set_maze_tile(maze_tiles, x, 15, Maze_tile.GHOST_SPAWN_BODER)

	for y in range(11, 16):
		_set_maze_tile(maze_tiles, 11, y, Maze_tile.GHOST_SPAWN_BODER)
		_set_maze_tile(maze_tiles, 20, y, Maze_tile.GHOST_SPAWN_BODER)


	# Ghost出生区
	for x in range(12, 20):
		for y in range(12, 15):
			_set_maze_tile(maze_tiles, x, y, Maze_tile.GHOST_SPAWN)
	for x in range(14, 18):
		_set_maze_tile(maze_tiles, x, 11, Maze_tile.GHOST_SPAWN)
	return maze_tiles

func _generate_maze_paths():
	var half_maze_cells = _generate_half_maze_cells()
	var half_maze_paths_reference: Array = []
	var half_maze_paths: Array = []
	half_maze_paths_reference.resize(half_path_height * half_path_width)
	half_maze_paths.resize(half_path_height * half_path_width)
	half_maze_paths.fill(Maze_tile.WALL)
	for index in range(half_cell_height * half_cell_width):
		var cell_x = index % half_cell_width
		var cell_y = int(index / half_cell_width)
		var flag = _get_half_maze_cell(half_maze_cells, cell_x, cell_y)
		for x in range(3):
			for y in range(3):
				_set_half_maze_path(half_maze_paths_reference, cell_x * 3 + x, cell_y * 3 + y, flag)

	# 根据不同的tetris flag设置路径。右边或者上面或右上不一样
	for x in range(half_path_width -1):
		for y in range(1, half_path_height):
			if (_get_half_maze_path(half_maze_paths_reference, x, y) != _get_half_maze_path(half_maze_paths_reference, x, y -1)
				or _get_half_maze_path(half_maze_paths_reference, x, y) != _get_half_maze_path(half_maze_paths_reference, x + 1, y)
				or _get_half_maze_path(half_maze_paths_reference, x, y) != _get_half_maze_path(half_maze_paths_reference, x + 1, y -1)
			):
				_set_half_maze_path(half_maze_paths, x, y, Maze_tile.PATH)

	return half_maze_paths

func _generate_half_maze_cells():
	var half_maze_cells = []
	half_maze_cells.resize(half_cell_height * half_cell_width)
	half_maze_cells.fill(0)
	# 相同flag的cell表示为同一个tetris
	var flag = 1
	# 预留Ghost生成点的位置
	_set_half_maze_cell(half_maze_cells, half_cell_width -1, GHOST_GATE_CELL_TOP, flag)
	_set_half_maze_cell(half_maze_cells, half_cell_width -1, GHOST_GATE_CELL_TOP + 1, flag)
	_set_half_maze_cell(half_maze_cells, half_cell_width -2, GHOST_GATE_CELL_TOP, flag)
	_set_half_maze_cell(half_maze_cells, half_cell_width -2, GHOST_GATE_CELL_TOP + 1, flag)

	flag += 1
	# 随机遍历所有cells，如果其为0，则生成tetris cells
	var cell_random_indexes = []
	for i in range(half_cell_width * half_cell_height):
		cell_random_indexes.append(i)
	_shuffle_array(cell_random_indexes)
	for index in cell_random_indexes:
		var x = index % half_cell_width
		var y = int(index / half_cell_width)
		if 0 == _get_half_maze_cell(half_maze_cells, x, y):
			_generate_tetris_cells_bfs(half_maze_cells, x, y, flag)
			flag += 1

	return half_maze_cells


func _generate_tetris_cells_bfs(half_maze_cells: Array, start_x: int, start_y: int, flag: int):
	var tc_cnt = _select_tetris_cell_count()
	var candidate_queue: Array = []
	candidate_queue.append(Vector2i(start_x, start_y))
	var cnt = 0
	while tc_cnt > 0 and !candidate_queue.is_empty():
		var now_cell_pos = candidate_queue.pop_front()
		var x = now_cell_pos.x
		var y = now_cell_pos.y
		_set_half_maze_cell(half_maze_cells, x, y, flag)
		tc_cnt -= 1
		cnt += 1

		var cell_neighbors = []
		# 左边邻居如果未访问
		if x -1 >= 0 and 0 == _get_half_maze_cell(half_maze_cells, x -1, y):
			cell_neighbors.append(Vector2i(x -1, y))
		# 右边邻居如果未访问
		if x + 1 < half_cell_width and 0 == _get_half_maze_cell(half_maze_cells, x + 1, y):
			cell_neighbors.append(Vector2i(x + 1, y))
		# 上
		if y -1 >= 0 and 0 == _get_half_maze_cell(half_maze_cells, x, y -1):
			cell_neighbors.append(Vector2i(x, y -1))
		# 下
		if y + 1 < half_cell_height and 0 == _get_half_maze_cell(half_maze_cells, x, y + 1):
			cell_neighbors.append(Vector2i(x, y + 1))

		_shuffle_array(cell_neighbors)

		for neighbor in cell_neighbors:
			candidate_queue.push_back(neighbor)

# 获取待生成的tetris的cell数量（1~5）
func _select_tetris_cell_count() -> int:
	var rand = rng.randi_range(0, 100)
	if rand < 5:
		return 1
	elif rand < 15:
		return 2
	elif rand < 35:
		return 3
	elif rand < 70:
		return 4
	else:
		return 5

static func _set_half_maze_cell(half_maze, x, y, value):
	if not (0 <= x and x < half_cell_width and 0 <= y and y < half_cell_height):
		push_error("index out of bounds")
		return
	half_maze[x + y * half_cell_width] = value

static func _get_half_maze_cell(half_maze_cells, x, y):
	if not (0 <= x and x < half_cell_width and 0 <= y and y < half_cell_height):
		push_error("index out of bounds")
		return
	return half_maze_cells[x + y * half_cell_width]

static func _set_half_maze_path(half_maze_paths, x, y, value):
	if not (0 <= x and x < half_path_width and 0 <= y and y < half_path_height):
		push_error("index out of bounds")
		return
	half_maze_paths[x + y * half_path_width] = value

static func _get_half_maze_path(half_maze_paths, x, y):
	if not (0 <= x and x < half_path_width and 0 <= y and y < half_path_height):
		push_error("index out of bounds")
		return
	return half_maze_paths[x + y * half_path_width]

static func _set_maze_tile(maze_tiles, x, y, value):
	if not (0 <= x and x < MAZE_TILE_WIDTH and 0 <= y and y < MAZE_TILE_HEIGHT):
		push_error("index out of bounds")
		return
	maze_tiles[x + y * MAZE_TILE_WIDTH] = value

static func get_maze_tile(maze_tiles, x, y):
	if not (0 <= x and x < MAZE_TILE_WIDTH and 0 <= y and y < MAZE_TILE_HEIGHT):
		push_error("index out of bounds")
		return
	return maze_tiles[x + y * MAZE_TILE_WIDTH]

func _shuffle_array(array: Array) -> Array:
	for i in range(array.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var temp = array[j]
		array[j] = array[i]
		array[i] = temp
	return array
