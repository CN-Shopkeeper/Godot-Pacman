extends Node2D

func _on_body_entered(body: Node2D) -> void:
	if "Pacman" in body.name:
		# todo 更新分数逻辑
		SignalBus.emit_dot_eaten(self)
		self.queue_free()
