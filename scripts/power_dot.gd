extends Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D

func _on_body_entered(body: Node2D) -> void:
	if "Pacman" in body.name:
		# todo 更新分数逻辑
		SignalBus.emit_dot_eaten("power_dot")
		self.queue_free()


func _on_timer_timeout() -> void:
	sprite_2d.visible = !sprite_2d.visible
