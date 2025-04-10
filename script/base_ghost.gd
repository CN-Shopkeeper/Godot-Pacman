class_name BaseGhost
extends BaseCharacter

@export var speed = 200

@export var floor_layer: TileMapLayer = null
@export var wall_layer: TileMapLayer = null
@export var visual_path_line2d: Line2D = null

var pathfinding_grid: AStarGrid2D = AStarGrid2D.new()
var spawn_pos: Vector2

var path_to_target: Array = []

func update_pathfinding_grid():
	pathfinding_grid.region = floor_layer.get_used_rect()
	pathfinding_grid.cell_size = GlobalVariables.tile_size
	pathfinding_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	pathfinding_grid.update()
	for cell in wall_layer.get_used_cells():
		pathfinding_grid.set_point_solid(cell, true)


func move_ghost(target_position: Vector2):
	# 每次走到tile中心时判断
	if Vector2.ZERO == target_position or not is_at_intersection():
		return

	var from_pos = grid_to_world(world_to_grid(position))
	path_to_target = pathfinding_grid.get_point_path(world_to_grid(position), world_to_grid(target_position))
	#print(target_position," size ",path_to_target.size())
	if path_to_target.size() > 1:
		var dir = (path_to_target[1]-path_to_target[0]).normalized()
		velocity = speed * dir

		if visual_path_line2d:
			visual_path_line2d.points = path_to_target
