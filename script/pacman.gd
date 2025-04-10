extends BaseCharacter


const SPEED = 200.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var at_state_machine = animation_tree["parameters/playback"]

@onready var turn_check_ray_cast_2d: RayCast2D = $TurnCheckRayCast2D



var blend_pos_path = "parameters/move/BlendSpace2D/blend_position"

var direction = D_RIGHT
var next_direction = Vector2i.ZERO

func _ready() -> void:
	position = grid_to_world(GlobalVariables.pacman_spawn_coor)


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("move_up"):
		next_direction = D_UP
	if Input.is_action_just_pressed("move_down"):
		next_direction = D_DOWN
	if Input.is_action_just_pressed("move_left"):
		next_direction = D_LEFT
	if Input.is_action_just_pressed("move_right"):
		next_direction = D_RIGHT

	_try_turn()
	_update_animation()
	move_and_slide()
	pass


func move_to_grid_center():
	position = grid_to_world(world_to_grid(position))

func _try_turn():
	if Vector2i.ZERO == next_direction:
		return
	turn_check_ray_cast_2d.set_target_position(next_direction * 20)
	turn_check_ray_cast_2d.force_raycast_update()

	if not turn_check_ray_cast_2d.is_colliding() and is_at_intersection():
		direction = next_direction
		next_direction = Vector2i.ZERO
		move_to_grid_center()
		velocity = direction * SPEED

func _update_animation():
	animation_tree.set(blend_pos_path, direction)
