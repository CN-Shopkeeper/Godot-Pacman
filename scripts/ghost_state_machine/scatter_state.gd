extends BaseState

func enter():
	# todo 修改样式
	ghost_node.speed = ghost_node.SCATTER_SPEED

func physics_update(delta: float):
	ghost_node.update_velocity(ghost_node.get_scatter_coor())

