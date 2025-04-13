extends Node

signal progress_changed(progress)
signal load_done
var _new_loading_screen
var _load_screen = preload("res://scenes/loading_screen.tscn")

var _loaded_resource: PackedScene
var _scene_path: String
var _progress: Array = []

var use_sub_threads: bool = true

func load_scene(scene_path: String) -> void:
	_scene_path = scene_path

	_new_loading_screen = _load_screen.instantiate()
	get_tree().get_root().add_child(_new_loading_screen)

	#self.progress_changed
	self.progress_changed.disconnect(_new_loading_screen._update_progress_bar)
	self.progress_changed.connect(_new_loading_screen._update_progress_bar)
	self.load_done.disconnect(_new_loading_screen._start_outro_animation)
	self.load_done.connect(_new_loading_screen._start_outro_animation)

	await Signal(_new_loading_screen, "Loading_screen_has_full_coverage")

	start_load()


func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(_scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)

func _process(_delta):
	var load_status = ResourceLoader.load_threaded_get_status(_scene_path, _progress)
	match load_status:
		0, 2:  # THREAD_LOAD_INVALID_RESOURCE, THREAD_LOAD_FAILED
			set_process(false)
		1:  # THREAD_LOAD_IN_PROGRESS
			emit_signal("progress_changed", _progress[0])
		3:  # THREAD_LOAD_LOADED
			_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)
			emit_signal("progress_changed", 1.0)
			emit_signal("load_done")
			await Signal(_new_loading_screen, "Loading_screen_starts_removing")
			get_tree().change_scene_to_packed(_loaded_resource)

