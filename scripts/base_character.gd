class_name BaseCharacter
extends CharacterBody2D

const D_LEFT = Vector2i.LEFT
const D_RIGHT = Vector2i.RIGHT
const D_UP = Vector2i.UP
const D_DOWN = Vector2i.DOWN

func is_at_intersection():
	var grid_pos = world_to_grid(position)
	return is_grid_center(grid_pos)

func is_grid_center(grid_pos):
	var local_pos = position - grid_to_world(grid_pos)
	return local_pos.length() < 3  # 接近中心点的阈值


func world_to_grid(world_pos):
	return Vector2(floor(world_pos.x / GlobalVariables.tile_size.x), floor(world_pos.y / GlobalVariables.tile_size.y))

func grid_to_world(grid_pos):
	return grid_pos * 1.0 * (GlobalVariables.tile_size * 1.0) + GlobalVariables.tile_size / 2.0  # 16是格子大小，8是中心
