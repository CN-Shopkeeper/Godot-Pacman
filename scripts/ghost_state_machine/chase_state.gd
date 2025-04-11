extends BaseState

func enter():
	# todo 修改样式
	ghost_node.speed = ghost_node.CHASE_BASE_SPEED

func physics_update(delta: float):
	ghost_node.update_velocity(ghost_node.get_chase_coor())
