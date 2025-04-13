class_name GhostInky
extends BaseGhost

@export var blinky_node: CharacterBody2D = null


func _ready() -> void:
	super._ready()
	#visual_path_line2d.global_position = GlobalVariables.tile_size/2

	reset()
	SignalBus.inky_time_to_go.connect(func():
		is_waiting = false
		change_to_action_state()
		print("inky coming")
		)

func _physics_process(delta: float) -> void:
	fsm.physics_update(delta)
	move_and_slide()

func reset():
	spawn_coor = GlobalVariables.inky_spawn_coor
	spawn_pos = grid_to_world(GlobalVariables.inky_spawn_coor)
	position = spawn_pos

func get_normal_texture() -> Texture2D:
	return preload("res://assets/sprites/ghosts/inky.png")

func get_chase_coor() -> Vector2i:
	if pacman_node and blinky_node:
		var pinky_target_coor = world_to_grid(pacman_node.position) + pacman_node.direction * 2
		var blinky_coor = world_to_grid(blinky_node.position)
		return blinky_coor + (pinky_target_coor -blinky_coor) * 2
	return Vector2i.ZERO

func get_scatter_coor() -> Vector2i:
	return GlobalVariables.bottom_right_corner_coor


func _on_area_2d_body_entered(body: Node2D) -> void:
	on_body_entered_func()
