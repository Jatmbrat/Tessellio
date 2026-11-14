extends Node


enum Display_modes {LEFT, CENTER, RIGHT, FREE}

var Options : Dictionary = {"Volume" : 0, "Music" : 0,  "Sound" : 0, "Anchor" : 2}
var data : Dictionary = {}
var data_ref : Dictionary = {}


func _ready() -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
	set_display(Options["Anchor"])
	data = Options.duplicate()


func clone_data() -> void:
	data_ref = data.duplicate()


func is_different() -> bool:
	var changes := 0
	if data != data_ref:
		changes = 1
		clone_data()
	return bool(changes)


func set_display(mode: int) -> void:
	data["Anchor"] = mode

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	if mode == Display_modes.FREE:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_size(get_viewport().content_scale_size)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DisplayServer.window_set_size(get_viewport().content_scale_size)
		DisplayServer.window_set_size(DisplayServer.window_get_size() * DisplayServer.screen_get_usable_rect().size.y / DisplayServer.window_get_size().y)

	var game_width : int = DisplayServer.window_get_size().x
	var left_edge : int = 0
	var left_edges := []
	var centers := []
	var right_edges := []
	var screen_number : int = DisplayServer.window_get_current_screen()
	for i in range(DisplayServer.get_screen_count()):
		var screen_width = DisplayServer.screen_get_size(i).x
		left_edges.append(left_edge)
		centers.append(left_edge + (screen_width * .5) - (game_width * .5))
		right_edges.append(left_edge + screen_width - game_width)
		left_edge += screen_width
	var positions = [left_edges, centers, right_edges]
	if mode == Display_modes.FREE:
		DisplayServer.window_set_position(
			Vector2i(centers[screen_number], int((DisplayServer.screen_get_size().y * .5) - DisplayServer.window_get_size().y * .5)))
	else:
		DisplayServer.window_set_position(
			Vector2i(positions[mode][screen_number], 0))

	DisplayServer.window_move_to_foreground()
