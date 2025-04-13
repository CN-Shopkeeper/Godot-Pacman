class_name BaseState
extends Node

@export var ghost_node: BaseGhost

# 进入状态时调用
func enter():
	pass

# 退出状态时调用
func exit():
	pass

# 每帧更新逻辑
func update(_delta: float):
	pass

# 物理帧更新逻辑
func physics_update(_delta: float):
	pass
