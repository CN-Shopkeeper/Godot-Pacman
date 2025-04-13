extends BaseState

func enter():
	# 修改样式
	ghost_node.sprite_2d.texture = ghost_node.get_normal_texture()
	ghost_node.modulate = Color.WHITE
	ghost_node.speed = ghost_node.CHASE_BASE_SPEED

func physics_update(_delta: float):
	ghost_node.update_velocity(ghost_node.get_chase_coor())
