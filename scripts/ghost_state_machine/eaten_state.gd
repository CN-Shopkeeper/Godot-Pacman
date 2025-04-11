extends BaseState


func enter():
	# todo 修改样式
	ghost_node.speed = ghost_node.EATEN_SPEED

func physics_update(delta: float):
	if ghost_node.is_return_to_spawn():
		# 这么写不够优雅
		ghost_node.fsm.switch_to(ghost_node.States.Idle)
	else:
		ghost_node.update_velocity(ghost_node.get_eaten_coor())
