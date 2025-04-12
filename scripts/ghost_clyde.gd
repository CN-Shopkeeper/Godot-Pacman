class_name GhostClyde
extends BaseGhost


func _ready() -> void:
	#visual_path_line2d.global_position = GlobalVariables.tile_size/2
	spawn_pos = grid_to_world(GlobalVariables.clyde_spawn_coor)
	position = spawn_pos
	SignalBus.clyde_time_to_go.connect(func():
		is_waiting = false
		change_state(States.Chase)
		print("clyde coming")
	)

func _physics_process(delta: float) -> void:
	fsm.physics_update(delta)
	move_and_slide()

func get_chase_coor() -> Vector2i:
	if pacman_node:
		var blinky_target_coor = world_to_grid(pacman_node.position)
		var paths = pathfinding_grid.get_point_path(world_to_grid(position), blinky_target_coor)
		var target_coor = blinky_target_coor if paths.size() > 8 else GlobalVariables.bottom_left_corner_coor
		return target_coor
	else:
		return Vector2i.ZERO

func get_scatter_coor() -> Vector2i:
	return GlobalVariables.bottom_left_corner_coor
