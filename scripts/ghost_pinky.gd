class_name GhostPinky
extends BaseGhost

@onready var timer: Timer = $Timer


func _ready() -> void:
	#visual_path_line2d.global_position = GlobalVariables.tile_size/2
	spawn_pos = grid_to_world(GlobalVariables.pinky_spawn_coor)
	position = spawn_pos
	
	timer.timeout.connect(func():
		is_waiting=false
		change_state(States.Chase)
		)

func _physics_process(delta: float) -> void:
	fsm.physics_update(delta)
	move_and_slide()

func get_chase_coor() -> Vector2i:
	if pacman_node:
		var target_coor = world_to_grid(pacman_node.position) + pacman_node.direction * 2
		return target_coor

	return Vector2i.ZERO

func get_scatter_coor() -> Vector2i:
	return GlobalVariables.top_left_corner_coor
