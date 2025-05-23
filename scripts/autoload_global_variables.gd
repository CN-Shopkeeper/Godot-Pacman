extends Node

@export_group("Resource Colors")
@export var main_menu_color: Color = Color(255, 142, 82, 255) / 256
@export var scene_transition_color: Color = Color(255, 255, 0, 255) / 256

@export_group("Game Constants")
@export var tile_size: Vector2 = Vector2(16, 16)
@export var pacman_spawn_coor: Vector2i = Vector2i(15, 28)
@export var blinky_spawn_coor: Vector2i = Vector2i(14, 13)
@export var clyde_spawn_coor: Vector2i = Vector2i(15, 13)
@export var inky_spawn_coor: Vector2i = Vector2i(16, 13)
@export var pinky_spawn_coor: Vector2i = Vector2i(17, 13)
@export var maze_size: Vector2i = Vector2i(32, 30)
@export var top_right_corner_coor: Vector2i = Vector2i(30, 1)
@export var bottom_left_corner_coor: Vector2i = Vector2i(1, 28)
@export var top_left_corner_coor: Vector2i = Vector2i(1, 1)
@export var bottom_right_corner_coor: Vector2i = Vector2i(30, 28)
@export var frightened_time_min: float = 5
@export var frightened_time_max: float = 10
