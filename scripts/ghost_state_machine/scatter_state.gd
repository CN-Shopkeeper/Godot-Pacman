extends BaseState

var reach_scatter_point = false
const DIRECTIONS = [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN]
var scatter_attemp_index = 0

func enter():
	reach_scatter_point = false
	# 修改样式
	ghost_node.sprite_2d.texture = ghost_node.get_normal_texture()
	ghost_node.modulate = Color.WHITE
	ghost_node.speed = ghost_node.CHASE_BASE_SPEED

func physics_update(delta: float):
	if not ghost_node.is_at_intersection():
		return
	var now_coor = ghost_node.world_to_grid(ghost_node.position)
	if not reach_scatter_point:
		reach_scatter_point = ghost_node.is_reach_scatter_point()
		# 确定起始方向
		# 如果刚到达scatter的角点，需要确定旋转的第一个方向。也可以直接硬编码
		if reach_scatter_point:
			var access_dirs_index = []
			for i in range(DIRECTIONS.size()):
				var tmp_coor = now_coor + DIRECTIONS[i]
				if MazeGenerator.is_ghost_accessible(GameData.maze, tmp_coor.x, tmp_coor.y):
					access_dirs_index.append(i)
			# 地图的角点，一定有两个方向可以移动，且这两个方向不是相对的（即相邻）
			# 选择顺时针方向靠后的方向
			if (access_dirs_index[0] + 1)%4 == access_dirs_index[1]:
				scatter_attemp_index = (access_dirs_index[1] + 2)%4
			else:
				scatter_attemp_index = (access_dirs_index[0] + 2)%4

			print(DIRECTIONS[scatter_attemp_index])

	if not reach_scatter_point:
		ghost_node.update_velocity(ghost_node.get_scatter_coor())

	else:
		var clockwise_coor_of_now_dir = now_coor + DIRECTIONS[(scatter_attemp_index + 1)%4]
		var counter_clock_coor_of_now_dir = now_coor + DIRECTIONS[(scatter_attemp_index + 3)%4]
		var now_dir_coor = now_coor + DIRECTIONS[scatter_attemp_index]
		# 尝试能否顺时针旋转
		if MazeGenerator.is_ghost_accessible(GameData.maze, clockwise_coor_of_now_dir.x, clockwise_coor_of_now_dir.y):
			ghost_node.update_velocity(clockwise_coor_of_now_dir)
			scatter_attemp_index = (scatter_attemp_index + 1)%4
		# 否则尝试直行
		elif MazeGenerator.is_ghost_accessible(GameData.maze, now_dir_coor.x, now_dir_coor.y):
			ghost_node.update_velocity(now_coor + DIRECTIONS[scatter_attemp_index])
		# 最后尝试逆时针
		else:
			ghost_node.update_velocity(counter_clock_coor_of_now_dir)
			scatter_attemp_index = (scatter_attemp_index + 3)%4
