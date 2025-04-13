extends Node

var maze
var dot_cnt_total: int
var dot_cnt_left: int

var frightened_time_left: float

var lives_remaining: int
var score: int
var consecutive_kills_cnt: int

func _ready() -> void:
	SignalBus.dot_eaten.connect(_on_dot_eaten)
	SignalBus.ghost_eaten.connect(_on_ghost_eaten)
	SignalBus.pacman_caught.connect(lives_reduce)

func init_game_record():
	lives_remaining = 2
	score = 0
	consecutive_kills_cnt = 0
	SignalBus.emit_lives_remaining_changed(lives_remaining)
	SignalBus.emit_score_changed(score)

func lives_reduce():
	if lives_remaining > 0:
		lives_remaining -= 1
		SignalBus.emit_lives_remaining_changed(lives_remaining)
	elif lives_remaining == 0:
		SignalBus.emit_no_lives_remains()


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

	score += 10
	SignalBus.emit_score_changed(score)

func _on_ghost_eaten():
	consecutive_kills_cnt += 1
	score += 200 * consecutive_kills_cnt
	SignalBus.emit_score_changed(score)
