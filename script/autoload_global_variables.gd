extends Node

@export_group("Resource Colors")
@export var main_menu_color: Color = Color(255, 142, 82, 255) / 256
@export var scene_transition_color: Color = Color(255, 255, 0, 255) / 256

@export_group("Game Constants")
@export var tile_size: Vector2i = Vector2i(16, 16)
@export var pacman_spawn_coor: Vector2i = Vector2i(15, 28)
