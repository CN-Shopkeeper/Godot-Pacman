extends BaseGhost

@onready var fsm: StateMachine = $FSM

enum States {Idle, Chase, Scatter, Frightened, Eaten}

func _ready() -> void:
	#visual_path_line2d.global_position = GlobalVariables.tile_size/2
	spawn_pos = grid_to_world(GlobalVariables.pinky_spawn_coor)
	position = spawn_pos

	fsm.switch_to(States.Idle)

func _physics_process(delta: float) -> void:
	fsm.physics_update(delta)
	move_and_slide()

func get_chase_coor() -> Vector2i:
	if pacman_node:
		var target_coor = world_to_grid(pacman_node.position) + pacman_node.direction * 2.0
		return target_coor

	return Vector2i.ZERO

func get_scatter_coor() -> Vector2i:
	return GlobalVariables.top_left_corner_coor
