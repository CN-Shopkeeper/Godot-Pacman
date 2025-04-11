class_name StateMachine
extends Node

var current_state: BaseState

# 切换到新状态
func switch_to(state_index: int):
	if current_state:
		current_state.exit()
	current_state = get_child(state_index)
	current_state.enter()

func physics_update(delta: float):
	current_state.physics_update(delta)
