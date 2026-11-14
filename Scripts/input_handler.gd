extends Node

var rc_held := false
var focus
var home


func _input(event: InputEvent) -> void:
	if StateHandler.state == StateHandler.States.IN_GAME or StateHandler.state == StateHandler.States.DRAWING:
		focus = get_child(0).get_child(0)
		var click_pos = focus.local_to_map(focus.get_local_mouse_position())
		if focus.is_fringe(click_pos) and event.is_action_pressed("interact"):
			focus.toggle_laser(click_pos, "line")
		if focus.is_fringe(click_pos) and event.is_action_pressed("clear"):
			focus.toggle_laser(click_pos, "cell")
		if event.is_action_pressed("scroll hovers right"):
			focus.hover_mode = (focus.hover_mode + 1) % focus.Hover_modes.size()
			SignalBus.hover_changed.emit(focus.hover_mode)
		if event.is_action_pressed("scroll hovers left"):
			focus.hover_mode = (focus.hover_mode + focus.Hover_modes.size() - 1) % focus.Hover_modes.size()
			SignalBus.hover_changed.emit(focus.hover_mode)
		if event.is_action_pressed("Undo"):
			SignalBus.undo_pressed.emit()
		if event.is_action_pressed("Reset"):
			SignalBus.level_reset.emit()
		if event.is_action_pressed("Redo"):
			SignalBus.redo_pressed.emit()
		if StateHandler.state == StateHandler.States.IN_GAME:
			if focus.is_on_map(click_pos):
				home = focus.centralize_shapes(click_pos)
				if event.is_action_pressed("interact") and not focus.is_locked(home):
					if focus.history.size() > Gl.QUEUE_SIZE:
						focus.history.pop_front()
					focus.history.append([home,[], "back"])
					focus.set_state(home, [], "forward")
					focus.redo_queue = []
					focus.audit_board()
				if event.is_action_pressed("clear"):
					rc_held = true
				if event.is_action_released("clear"):
					rc_held = false


func _process(_delta: float) -> void:
	if StateHandler.state == StateHandler.States.IN_GAME:
		focus = get_child(0).get_child(0)
		var mouse_pos = focus.local_to_map(focus.get_local_mouse_position())
		if focus.is_on_map(mouse_pos):
			home = focus.centralize_shapes(mouse_pos)
			if rc_held and not (focus.is_locked(home) or focus.is_stateless(home)):
				var shape : Array = focus.get_shape_cells(home)
				var layer : Array = focus.get_layer_key(home)
				focus.history.append([home, focus.color_sets[int(focus.is_on(home))], "forward"])
				if focus.history.size() > Gl.QUEUE_SIZE:
					focus.history.pop_front()
				focus.redo_queue = []
				for i in shape.size():
					focus.get_child(focus.Layers.STATE + layer[i]).erase_cell(shape[i])
				focus.audit_board()
