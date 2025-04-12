extends BaseState
const BLUE_GHOST = preload("res://assets/sprites/ghosts/blue_ghost.png")

func enter():
	# 修改样式
	ghost_node.sprite_2d.texture = BLUE_GHOST
	ghost_node.modulate = Color(1, 1, 1, 0.5)
	ghost_node.speed = ghost_node.EATEN_SPEED

func physics_update(delta: float):
	if ghost_node.is_return_to_spawn():
		ghost_node.change_state(BaseGhost.States.Idle)
		get_tree().create_timer(1).timeout.connect(func():
			if BaseGhost.States.Idle == ghost_node.now_state:
				ghost_node.change_state(BaseGhost.States.Chase)
				)
	else:
		ghost_node.update_velocity(ghost_node.get_eaten_coor())
