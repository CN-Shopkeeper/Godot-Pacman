extends Node

@export_group("Resource Colors")
@export var main_menu_color: Color = Color(255, 142, 82, 255) / 256
@export var scene_transition_color: Color = Color(255, 255, 0, 255) / 256

@export_group("Game Constants")
@export var tile_size: Vector2 = Vector2(16, 16)
@export var pacman_spawn_coor: Vector2i = Vector2i(15, 28)
@export var blinky_spawn_coor: Vector2i = Vector2i(13, 13)
@export var clyde_spawn_coor: Vector2i = Vector2i(14, 13)
@export var inky_spawn_coor: Vector2i = Vector2i(15, 13)
@export var pinky_spawn_coor: Vector2i = Vector2i(16, 13)
@export var maze_size: Vector2i = Vector2i(32, 30)
