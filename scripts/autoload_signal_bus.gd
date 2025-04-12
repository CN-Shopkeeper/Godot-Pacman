extends Node

signal dot_eaten(dot)
signal ghost_eaten
signal inky_time_to_go
signal clyde_time_to_go
signal dot_eaten_all

func emit_dot_eaten(dot) -> void:
	emit_signal("dot_eaten", dot)

func emit_ghost_eaten() -> void:
	emit_signal("ghost_eaten")

func emit_inky_time_to_go() -> void:
	emit_signal("inky_time_to_go")

func emit_clyde_time_to_go() -> void:
	emit_signal("clyde_time_to_go")

func emit_dot_eaten_all() -> void:
	emit_signal("dot_eaten_all")
