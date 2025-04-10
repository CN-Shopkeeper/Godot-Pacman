extends BaseGhost

func _ready() -> void:
	#visual_path_line2d.global_position = GlobalVariables.tile_size/2
	spawn_pos = grid_to_world(GlobalVariables.blinky_spawn_coor)
	position = spawn_pos

func _physics_process(delta: float) -> void:
	move_ghost(Vector2(16, 16))
	move_and_slide()
