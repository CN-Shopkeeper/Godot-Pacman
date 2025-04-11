extends BaseGhost

@onready var fsm: StateMachine = $FSM

enum States {Idle, Chase, Scatter}

# todo angry mode
func _ready() -> void:
	#visual_path_line2d.global_position = GlobalVariables.tile_size/2
	spawn_pos = grid_to_world(GlobalVariables.blinky_spawn_coor)
	position = spawn_pos

	fsm.switch_to(States.Scatter)


func _physics_process(delta: float) -> void:
	fsm.physics_update(delta)
	move_and_slide()

func get_chase_coor() -> Vector2i:
	return world_to_grid(pacman_node.position)

func get_scatter_coor() -> Vector2i:
	return GlobalVariables.top_right_corner_coor
