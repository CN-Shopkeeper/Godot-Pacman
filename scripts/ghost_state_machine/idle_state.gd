extends BaseState

func enter():
	# todo 修改样式
	ghost_node.speed = 0
	ghost_node.velocity = Vector2.ZERO

func physics_update(delta: float):
	pass
