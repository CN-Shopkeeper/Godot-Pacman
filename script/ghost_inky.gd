extends BaseGhost

@export var blinky_node: CharacterBody2D = null

func _ready() -> void:
	#visual_path_line2d.global_position = GlobalVariables.tile_size/2
	spawn_pos = grid_to_world(GlobalVariables.inky_spawn_coor)
	position = spawn_pos

func _physics_process(delta: float) -> void:
	if pacman_node and blinky_node:
		var pinky_target_coor = world_to_grid(pacman_node.position) + pacman_node.direction * 2.0
		var blinky_coor = world_to_grid(blinky_node.position)
		var target_coor = blinky_coor + (pinky_target_coor -blinky_coor) * 2
		move_ghost(target_coor)
	move_and_slide()
