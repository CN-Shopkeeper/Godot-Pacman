extends CanvasLayer

signal Loading_screen_has_full_coverage
signal Loading_screen_starts_removing
@onready var panel: Panel = $Panel

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var progressBar: ProgressBar = $Panel/ProgressBar

func _update_progress_bar(new_value: float) -> void:
	progressBar.set_value_no_signal(new_value * 100)

func _start_outro_animation() -> void:
	if animationPlayer.is_playing():
		await Signal(animationPlayer, "animation_finished")
	animationPlayer.play("end_load")
	if animationPlayer.is_playing():
		await Signal(animationPlayer, "animation_finished")
	self.queue_free()
