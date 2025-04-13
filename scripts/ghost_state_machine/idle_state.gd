extends BaseState

func enter():
	# 修改样式
	ghost_node.sprite_2d.texture = ghost_node.get_normal_texture()
	ghost_node.modulate = Color.WHITE
	ghost_node.speed = 0
	ghost_node.velocity = Vector2.ZERO

func physics_update(_delta: float):
	pass
