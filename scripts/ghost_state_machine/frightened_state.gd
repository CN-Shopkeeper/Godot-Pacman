extends BaseState

const BLUE_GHOST = preload("res://assets/sprites/ghosts/blue_ghost.png")

func enter():
	# 修改样式
	ghost_node.sprite_2d.texture = BLUE_GHOST
	ghost_node.modulate = Color.WHITE
	ghost_node.speed = ghost_node.FRIGHTENED_SPEED


func physics_update(_delta: float):
	if GameData.frightened_time_left > 0 and GameData.frightened_time_left <= 3.0 and ghost_node.timer.is_stopped():
		ghost_node.timer.start()
	if GameData.frightened_time_left > 3 and not ghost_node.timer.is_stopped():
		ghost_node.timer.stop()
	ghost_node.update_velocity(ghost_node.get_frightened_coor())

func exit():
	ghost_node.timer.stop()
	ghost_node.visible = true
