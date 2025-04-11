extends BaseGhost

@export var blinky_node: CharacterBody2D = null

@onready var fsm: StateMachine = $FSM

enum States {Idle, Chase, Scatter}

func _ready() -> void:
	#visual_path_line2d.global_position = GlobalVariables.tile_size/2
	spawn_pos = grid_to_world(GlobalVariables.inky_spawn_coor)
	position = spawn_pos

	fsm.switch_to(States.Scatter)

func _physics_process(delta: float) -> void:
	fsm.physics_update(delta)
	move_and_slide()

func get_chase_coor() -> Vector2i:
	if pacman_node and blinky_node:
		var pinky_target_coor = world_to_grid(pacman_node.position) + pacman_node.direction * 2.0
		var blinky_coor = world_to_grid(blinky_node.position)
		return blinky_coor + (pinky_target_coor -blinky_coor) * 2
	return Vector2i.ZERO

func get_scatter_coor() -> Vector2i:
	return GlobalVariables.bottom_right_corner_coor
