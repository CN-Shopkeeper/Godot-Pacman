extends BaseGhost

# todo angry mode
func _ready() -> void:
	#visual_path_line2d.global_position = GlobalVariables.tile_size/2
	spawn_pos = grid_to_world(GlobalVariables.blinky_spawn_coor)
	position = spawn_pos

func _physics_process(delta: float) -> void:
	if pacman_node:
		var target_coor = world_to_grid(pacman_node.position)
		move_ghost(target_coor)
	move_and_slide()
