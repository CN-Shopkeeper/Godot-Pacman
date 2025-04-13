class_name GhostPinky
extends BaseGhost


func _ready() -> void:
	super._ready()
	#visual_path_line2d.global_position = GlobalVariables.tile_size/2
	reset()
	get_tree().create_timer(5).timeout.connect(func():
		is_waiting = false
		change_state(States.Scatter))


func _physics_process(delta: float) -> void:
	fsm.physics_update(delta)
	move_and_slide()

func reset():
	spawn_coor = GlobalVariables.pinky_spawn_coor
	spawn_pos = grid_to_world(GlobalVariables.pinky_spawn_coor)
	position = spawn_pos

func get_normal_texture() -> Texture2D:
	return preload("res://assets/sprites/ghosts/pinky.png")

func get_chase_coor() -> Vector2i:
	if pacman_node:
		var target_coor = world_to_grid(pacman_node.position) + pacman_node.direction * 2
		return target_coor

	return Vector2i.ZERO

func get_scatter_coor() -> Vector2i:
	return GlobalVariables.top_left_corner_coor


func _on_area_2d_body_entered(body: Node2D) -> void:
	on_body_entered_func()
