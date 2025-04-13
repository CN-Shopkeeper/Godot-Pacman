class_name BaseGhost
extends BaseCharacter


@export var floor_layer: TileMapLayer = null
@export var wall_layer: TileMapLayer = null
@export var visual_path_line2d: Line2D = null
@export var pacman_node: CharacterBody2D = null

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var fsm: StateMachine = $FSM
@onready var timer: Timer = $Timer

enum States {Idle, Chase, Scatter, Frightened, Eaten}

const CHASE_BASE_SPEED = 240
const FRIGHTENED_SPEED = 160
const EATEN_SPEED = 384

var is_waiting = true
var now_state: States
var now_dir: Vector2i

var pathfinding_grid: AStarGrid2D = AStarGrid2D.new()
var spawn_coor: Vector2i
var spawn_pos: Vector2

var path_to_target: Array = []

func _ready() -> void:
	timer.timeout.connect(func():
		visible = !visible
	)

func change_state(new_state: States):
	if is_waiting:
		return
	fsm.switch_to(new_state)
	now_state = new_state

func change_to_action_state():
	# eaten状态只能进入idle状态
	if now_state != States.Eaten:
		change_state(GameData.now_ghost_action_mode)

func update_pathfinding_grid():
	pathfinding_grid.region = floor_layer.get_used_rect()
	pathfinding_grid.cell_size = GlobalVariables.tile_size
	pathfinding_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	pathfinding_grid.update()
	for cell in wall_layer.get_used_cells():
		pathfinding_grid.set_point_solid(cell, true)

func update_velocity(target_coor: Vector2i):
	# 每次走到tile中心时判断
	if Vector2i.ZERO == target_coor or not is_at_intersection():
		return
	target_coor = MazeGenerator.get_nearest_ghost_access_coor(GameData.maze, target_coor.x, target_coor.y)

	path_to_target = pathfinding_grid.get_point_path(world_to_grid(position), target_coor)
	if path_to_target.size() > 1:
		var dir = (path_to_target[1]-path_to_target[0]).normalized()
		now_dir = Vector2i(floor(dir.x), floor(dir.y))
		velocity = speed * dir
		if visual_path_line2d:
			visual_path_line2d.points = path_to_target

func get_normal_texture() -> Texture2D:
	return preload("res://assets/sprites/ghosts/blue_ghost.png")

func get_chase_coor() -> Vector2i:
	return Vector2i.ZERO

func get_scatter_coor() -> Vector2i:
	return Vector2i.ZERO

func get_frightened_coor() -> Vector2i:
	var now_coor = world_to_grid(position)
	var access_dirs = MazeGenerator.get_ghost_access_dirs(GameData.maze, now_coor.x, now_coor.y)

	if access_dirs.is_empty():
		return now_coor
	var front_dir_index = access_dirs.find(now_dir)
	var behind_dir_index = access_dirs.find(-now_dir)
	# 如果前进方向可用时，不可向后转
	if -1 != behind_dir_index and -1 != front_dir_index:
		access_dirs.remove_at(behind_dir_index)
	var weights = []
	var total_weights = 0
	for dir in access_dirs:
		if dir == now_dir:
			weights.append(0.3)
			total_weights += 0.3
		else:
			weights.append(0.1)
			total_weights += 0.1

	var roll = randf_range(0, total_weights)
	var cumulative = 0

	for i in access_dirs.size():
		cumulative += weights[i]
		if roll <= cumulative:
			return now_coor + access_dirs[i]

	return now_coor + access_dirs[0]

func get_eaten_coor() -> Vector2i:
	return spawn_coor

func on_body_entered_func():
	var current_state_name = fsm.current_state.name
	if current_state_name == "Frightened":
		SignalBus.emit_ghost_eaten()
		change_state(States.Eaten)
	elif -1 != ["Chase", "Scatter"].find(current_state_name):
		SignalBus.emit_pacman_caught()


func is_return_to_spawn():
	if world_to_grid(position) == spawn_coor:
		move_to_grid_center()
		return true
	return false

func is_reach_scatter_point():
	if world_to_grid(position) == get_scatter_coor():
		move_to_grid_center()
		return true
	return false
