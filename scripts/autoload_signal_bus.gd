extends Node

signal dot_eaten(dot)
signal ghost_eaten
signal pacman_caught
signal inky_time_to_go
signal clyde_time_to_go
signal dot_eaten_all
signal lives_remaining_changed(lives_remaining)
signal no_lives_remains
signal score_changed(score)

func emit_dot_eaten(dot) -> void:
	emit_signal("dot_eaten", dot)

func emit_ghost_eaten() -> void:
	emit_signal("ghost_eaten")

func emit_pacman_caught() -> void:
	emit_signal("pacman_caught")

func emit_inky_time_to_go() -> void:
	emit_signal("inky_time_to_go")

func emit_clyde_time_to_go() -> void:
	emit_signal("clyde_time_to_go")

func emit_dot_eaten_all() -> void:
	emit_signal("dot_eaten_all")

func emit_lives_remaining_changed(lives_remaining) -> void:
	emit_signal("lives_remaining_changed", lives_remaining)

func emit_score_changed(score) -> void:
	emit_signal("score_changed", score)

func emit_no_lives_remains() -> void:
	emit_signal("no_lives_remains")
