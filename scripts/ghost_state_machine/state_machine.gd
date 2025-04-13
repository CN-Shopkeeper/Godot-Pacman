class_name StateMachine
extends Node

var current_state: BaseState

func _ready() -> void:
	current_state = get_child(0)

# 切换到新状态
func switch_to(state_index: int):
	var new_state = get_child(state_index)
	if new_state == current_state:
		return
	# 如果被吃了，就不进入恐惧状态
	if current_state.name == "Eaten" and new_state.name == "Frightened":
		return
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()

func physics_update(delta: float):
	current_state.physics_update(delta)
