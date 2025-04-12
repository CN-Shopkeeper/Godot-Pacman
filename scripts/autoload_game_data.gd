extends Node

var maze
var dot_cnt_total: int
var dot_cnt_left: int

var frightened_time_left: float

func _ready() -> void:
	SignalBus.dot_eaten.connect(_on_dot_eaten)

func init_maze(_maze, dot_cnt):
	maze = _maze
	dot_cnt_total = dot_cnt
	dot_cnt_left = dot_cnt

func _on_dot_eaten(_dot):
	dot_cnt_left -= 1
	if dot_cnt_total -dot_cnt_left == 30:
		SignalBus.emit_inky_time_to_go()

	if dot_cnt_total -dot_cnt_left == 60:
		SignalBus.emit_clyde_time_to_go()

	if 0 == dot_cnt_left:
		SignalBus.emit_dot_eaten_all()
