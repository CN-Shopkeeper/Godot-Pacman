extends BaseGhost

func _ready() -> void:
	#visual_path_line2d.global_position = GlobalVariables.tile_size/2
	spawn_pos = grid_to_world(GlobalVariables.pinky_spawn_coor)
	position = spawn_pos

func _physics_process(delta: float) -> void:
	if pacman_node:
		var target_coor = world_to_grid(pacman_node.position) + pacman_node.direction * 2.0

		move_ghost(target_coor)
	move_and_slide()
