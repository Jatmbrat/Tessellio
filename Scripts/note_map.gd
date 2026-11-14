extends TileMapLayer


var lc_held := false
var rc_held := false
var start_point : Vector2i


func _ready() -> void:
	load_notes()
	get_parent().all_set = true


func load_notes() -> void:
	for i in get_parent().notes:
		set_cell(Vector2i(i[0], i[1]), 1, Vector2i(0, 0))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Clear Notes"):
		clear()
	if event.is_action_pressed("interact"):
		lc_held = true
		start_point = local_to_map(get_local_mouse_position()) 
	if event.is_action_released("interact"):
		lc_held = false
	if event.is_action_pressed("clear"):
		rc_held = true
		start_point = local_to_map(get_local_mouse_position())
	if event.is_action_released("clear"):
		rc_held = false


func _process(_delta: float) -> void:
	if not StateHandler.state == StateHandler.States.DRAWING:
		return
	if not (lc_held or rc_held):
		return
	var parent_pos = get_parent().local_to_map(get_parent().get_local_mouse_position())

	if not get_parent().is_on_map(parent_pos):
		start_point = Vector2i(-1, -1)
		return
	
	var click_pos = local_to_map(get_local_mouse_position())
	if start_point == Vector2i(-1, -1):
		start_point = click_pos
	
	var small := []
	var block := []
	var current_cell

	var x_a = start_point.x
	var y_a = start_point.y
	var x_b = click_pos.x
	var y_b = click_pos.y

	if abs(x_b - x_a) > abs(y_b - y_a):

		if x_a > x_b:
			x_a = click_pos.x
			x_b = start_point.x
			y_a = click_pos.y
			y_b = start_point.y

		var d_x = x_b - x_a
		var d_y = y_b - y_a

		var dir = -1 if d_y < 0 else 1
		d_y *= dir

		if d_x != 0:
			var y = y_a
			var p = 2 * d_y - d_x
			for i in range(d_x + 1):

				for a in range(2):
					for b in range(2):
						current_cell = Vector2i(x_a + i, y) + Vector2i(a - 1, b - 1)
						small.append(current_cell)

				for a in range(7):
					for b in range(7):
						current_cell = Vector2i(x_a + i, y) + Vector2i(a - 3, b - 3)
						block.append(current_cell)

				if lc_held:
					for j in small:
						set_cell(j, 1, Vector2i(0, 0))
				else:
					for j in block:
						erase_cell(j)

				if p >= 0:
					y += dir
					p = p - 2 * d_x
				p = p + 2 * d_y

	else:
		if y_a > y_b:
			x_a = click_pos.x
			x_b = start_point.x
			y_a = click_pos.y
			y_b = start_point.y

		var d_x = x_b - x_a
		var d_y = y_b - y_a

		var dir = -1 if d_x < 0 else 1
		d_x *= dir

		if d_y != 0:
			var x = x_a
			var p = 2 * d_x - d_y
			for i in range(d_y + 1):

				for a in range(2):
					for b in range(2):
						current_cell = Vector2i(x, y_a + i) + Vector2i(a - 1, b - 1)
						small.append(current_cell)

				for a in range(7):
					for b in range(7):
						current_cell = Vector2i(x, y_a + i) + Vector2i(a - 3, b - 3)
						block.append(current_cell)

				if lc_held:
					for j in small:
						set_cell(j, 1, Vector2i(0, 0))

				else:
					for j in block:
						erase_cell(j)

				if p >= 0:
					x += dir
					p = p - 2 * d_y
				p = p + 2 * d_x

	start_point = click_pos
