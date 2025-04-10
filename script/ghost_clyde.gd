extends BaseGhost

func _ready() -> void:
	#visual_path_line2d.global_position = GlobalVariables.tile_size/2
	spawn_pos = grid_to_world(GlobalVariables.clyde_spawn_coor)
	position = spawn_pos

func _physics_process(delta: float) -> void:
	if pacman_node:
		var blinky_target_coor = world_to_grid(pacman_node.position)
		var paths = pathfinding_grid.get_point_path(world_to_grid(position), blinky_target_coor)
		var target_coor = blinky_target_coor if paths.size() > 8 else GlobalVariables.bottom_left_corner_coor

		move_ghost(target_coor)
	move_and_slide()
