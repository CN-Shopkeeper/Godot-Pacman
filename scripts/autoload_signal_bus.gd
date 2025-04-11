extends Node

signal dot_eaten(dot)

func emit_dot_eaten(dot) -> void:
	emit_signal("dot_eaten", dot)
