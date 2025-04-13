class_name GhostBlinky
extends BaseGhost

# todo angry mode
func _ready() -> void:
	super._ready()
	is_waiting = false
	#visual_path_line2d.global_position = GlobalVariables.tile_size/2
	reset()


func _physics_process(delta: float) -> void:
	fsm.physics_update(delta)
	move_and_slide()

func reset():
	spawn_coor = GlobalVariables.blinky_spawn_coor
	spawn_pos = grid_to_world(GlobalVariables.blinky_spawn_coor)
	position = spawn_pos
	change_state(States.Scatter)

func get_normal_texture() -> Texture2D:
	return preload("res://assets/sprites/ghosts/blinky.png")

func get_chase_coor() -> Vector2i:
	return world_to_grid(pacman_node.position)

func get_scatter_coor() -> Vector2i:
	return GlobalVariables.top_right_corner_coor


func _on_area_2d_body_entered(body: Node2D) -> void:
	# 默认只有pacman与之交互碰撞
	on_body_entered_func()
