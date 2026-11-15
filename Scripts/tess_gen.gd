extends TileMapLayer

const ROWS := 10
const COLS := 10
const CELL_SIZE := 32
const BOARD_POSITION = Vector2(0, 0)

const ROW_WIDTH := Vector2i(COLS, 0)
const ROW_UNIT := Vector2i(1, 0)
const COLUMN_LENGTH := Vector2i(0, ROWS)
const COLUMN_UNIT := Vector2i(0, 1)
const DIAGONAL_UNIT := Vector2i(1, 1)
const DIAGONAL_SPAN := Vector2i(COLS, ROWS)

const SMALL_BG := Vector2i(4, 1)
const CORNER_BG := Vector2i(5, 1)
const SMALL_ON := Vector2i(1, 1)
const CORNER_ON := Vector2i(2, 1)
const SMALL_OFF := Vector2i(0, 1)
const CORNER_OFF := Vector2i(3, 1)
const SMALL_HOVER := Vector2i(5, 0)
const CORNER_HOVER := Vector2i(6, 0)
const SMALL_EX_HOVER := Vector2i(7, 0)
const CORNER_EX_HOVER := Vector2i(8, 0)
const FRINGE_HOVER := Vector2i(9, 0)
const CELL_HOVER := Vector2i(0, 0)
const FRINGE_CELL := Vector2i(1, 0)
const FRINGE_CORNER := Vector2i(10, 0)
const FRINGE_OFF := Vector2i(11, 0)
const FRINGE_ON := Vector2i(12, 0)
const LINE_BEAM := Vector2i(10, 1)
const SMALL_LINEAR := Vector2i(11, 1)
const CORNER_LINEAR := Vector2i(12, 1)
const DATA_TILE := Vector2i(12, 2)

enum Layers {
	BG, DECAL, STATE, CLUE, EXTRA, LOCKED, FRINGE, HOVER, CELL_HOVER, COLUMN, ROW, GRID, WIN, WRONG, RIGHT, TIMER
}

enum Hover_modes {
	SINGLE, QUAD, ADJACENT
}

var hover_mode : int = 0

var tile_id : int = 0

var bg_set = [
	SMALL_BG, CORNER_BG, CORNER_BG, CORNER_BG, CORNER_BG
	]
var off_set = [
	SMALL_OFF, CORNER_OFF, CORNER_OFF, CORNER_OFF, CORNER_OFF
	]
var on_set = [
	SMALL_ON, CORNER_ON, CORNER_ON, CORNER_ON, CORNER_ON
	]
var color_sets = [
	off_set, on_set
]
var hover_set = [
	SMALL_HOVER, CORNER_HOVER, CORNER_HOVER, CORNER_HOVER, CORNER_HOVER
	]
var focus_set = [
	SMALL_EX_HOVER, CORNER_EX_HOVER, CORNER_EX_HOVER, CORNER_EX_HOVER, CORNER_EX_HOVER
	]

var x_cols := []
var x_off := []
var x_on := []
var y_rows := []
var y_off := []
var y_on := []
var spin_key := [0, 1, 5, 4]
var big_rotation : int
var tiling_offset : int
var spots : Dictionary = {}
var spot_format : Dictionary = {
	"landmark" : Vector2i(),
	"cols" : [],
	"rows" : [],
	"quad" : [],
	"adjacent" : 0,
	"order" : 0
}
var initial_state : Dictionary = {}
var target_state : Dictionary = {}
var current_state : Dictionary  = {}
var valid_board : bool
var level_set : String
var history := []
var redo_queue := []
var notes := []
var all_set := false

func _ready() -> void:
	level_set = get_parent().level_set
	set_board_parameters()
	new_game()
	SignalBus.state_changed.emit(StateHandler.States.IN_GAME)
	SignalBus.level_reset.connect(_on_level_reset)
	SignalBus.undo_pressed.connect(_on_undo_pressed)
	SignalBus.redo_pressed.connect(_on_redo_pressed)


func new_game() -> void:
	create_shapes(Layers.BG, bg_set)
	set_lasers()
	check_lines()
	set_starting()
	if current_state.is_empty():
		get_current_board(Gl.Modes.CURRENT)
		set_board_parameters()
	set_current()


func set_board_parameters() -> void:
	var level_info = LevelData.data[level_set]["lv" + str(get_parent().level_data_index)].duplicate()
	big_rotation = int(level_info["rotation"])
	tiling_offset = int(level_info["offset"])
	initial_state = level_info["initial"]
	target_state = level_info["target"]
	notes = level_info["notes"]
	if level_info.has("current"):
		current_state = level_info["current"]


func create_shapes(layer : int, tileset : Array) -> void:
	for y in range(ROWS):
		for x in range(COLS):
			if is_landmark(Vector2i(x, y)):
				set_cell(Vector2i(x, y), tile_id, DATA_TILE)
				var shape = get_shape_cells(Vector2i(x, y))
				var tile = get_tile_key(Vector2i(x, y))
				for i in shape.size():
					get_child(layer).set_cell(shape[i], tile_id, tileset[tile[i]], Gl.ROTS[spin_key[i]])


func set_lasers() -> void:
	for i in range(2):
		for j in get_child(Layers.COLUMN + i).get_used_cells():
			erase_cell(j)
	for x in range(COLS):
		get_child(Layers.FRINGE).set_cell(Vector2i(x, -1), tile_id, FRINGE_OFF)
		get_child(Layers.FRINGE).set_cell(Vector2i(x, ROWS), tile_id, FRINGE_OFF, Gl.ROTS[4])
	for y in range(ROWS):
		get_child(Layers.FRINGE).set_cell(Vector2i(-1, y), tile_id, FRINGE_OFF, Gl.ROTS[6])
		get_child(Layers.FRINGE).set_cell(Vector2i(COLS, y), tile_id, FRINGE_OFF, Gl.ROTS[2])
	var corners := [Vector2i(-1, -1), Vector2i(COLS, -1), Vector2i(-1, ROWS), Vector2i(COLS, ROWS)]
	for i in corners.size():
		get_child(Layers.BG).set_cell(corners[i], tile_id, FRINGE_CORNER, Gl.ROTS[spin_key[i]])


func check_lines() -> void:
	for x in range(COLS):
		x_cols.append([])
		x_off.append([])
		x_on.append([])
	for y in range(ROWS):
		y_rows.append([])
		y_off.append([])
		y_on.append([])
	for i in range(get_used_cells().size()):
		spots["S" + str(i)] = spot_format.duplicate()
		spots["S" + str(i)]["landmark"] = get_used_cells()[i]
		var x_cells := []
		var y_cells := []
		for j in get_shape_cells(spots["S" + str(i)]["landmark"]):
			if not x_cells.has(j.x):
				x_cells.append(j.x)
			if not y_cells.has(j.y):
				y_cells.append(j.y)
		for j in x_cells:
			x_cols[j].append(i)
		for j in y_cells:
			y_rows[j].append(i)
		spots["S" + str(i)]["cols"] = x_cells
		spots["S" + str(i)]["rows"] = y_cells
		spots["S" + str(i)]["quad"] = get_linked_set(spots["S" + str(i)]["landmark"])


func _on_level_reset() -> void:
	if StateHandler.state == StateHandler.States.IN_GAME:
		redo_queue = []
		if not history.is_empty():
			if not history.back().size() > 3:
				get_current_board(Gl.Modes.HISTORY)
		set_starting()
		audit_board()


func _on_undo_pressed() -> void:
	if StateHandler.state != StateHandler.States.IN_GAME:
		return
	revise_history()


func _on_redo_pressed() -> void:
	if StateHandler.state != StateHandler.States.IN_GAME:
		return
	if redo_queue.is_empty():
		return
	if redo_queue.back().is_empty():
		get_current_board(Gl.Modes.HISTORY)
		redo_queue.pop_back()
	else:
		if history.size() > Gl.QUEUE_SIZE:
			history.pop_front()
		history.append(redo_queue.back())
		if redo_queue.back()[1].is_empty():
			set_state(redo_queue.back()[0], redo_queue.back()[1], "forward")
		else:
			var shape = get_shape_cells(redo_queue.back()[0])
			for i in shape.size():
				get_child(Layers.STATE).erase_cell(shape[i])
		redo_queue.pop_back()
	audit_board()


func set_starting() -> void:
	get_child(Layers.STATE).clear()
	for i in spots.size():
		if initial_state["I" + str(i)] == target_state["T" + str(i)]:
			get_child(Layers.LOCKED).set_cell(spots["S" + str(i)]["landmark"], tile_id, DATA_TILE)
			set_state(spots["S" + str(i)]["landmark"], color_sets[target_state["T" + str(i)]], "forward")


func set_current() -> void:
	var loaded_start := false
	for i in spots.size():
		if current_state["C" + str(i)] != initial_state["I" + str(i)]:
			loaded_start = true
		if current_state["C" + str(i)] >= 0:
			set_state(spots["S" + str(i)]["landmark"], color_sets[current_state["C" + str(i)]], "forward")
	if loaded_start:
		get_current_board(Gl.Modes.HISTORY)


func set_history() -> void:
	if history.is_empty():
		return
	for i in spots.size():
		current_state["C" + str(i)] = history.back()[i]
		if current_state["C" + str(i)] >= 0:
			set_state(spots["S" + str(i)]["landmark"], color_sets[current_state["C" + str(i)]], "forward")
	history.pop_back()


func revise_history() -> void:
	if history.is_empty():
		return
	if history.back().size() > 3:
		set_history()
		redo_queue.append([])
	else:
		set_state(history.back()[0], history.back()[1], history.back()[2])
		redo_queue.append(history.back())
		history.pop_back()
	audit_board()


func wrap_cells(i : Vector2i) -> Vector2i:
	if i.x < 0:
		i += ROW_WIDTH
	if i.x >= COLS:
		i -= ROW_WIDTH
	if i.y < 0:
		i += COLUMN_LENGTH
	if i.y >= ROWS:
		i -= COLUMN_LENGTH
	return i


func centralize_shapes(i : Vector2i):
	if is_big_top_left(i + (4 * ROW_UNIT)):
		i -= ROW_UNIT
	if is_big_top_left(i + (4 * COLUMN_UNIT)):
		i -= COLUMN_UNIT
	if is_big_top_left(i + (4 * DIAGONAL_UNIT)):
		i -= DIAGONAL_UNIT
	return wrap_cells(i)


func get_layer_key(i : Vector2i) -> Array:
	if is_small_tile(i):
		return [0]
	else:
		return [0, 0, 0, 0]


func get_shape_cells(i : Vector2i) -> Array:
	var shape_cells := []
	var size : int = 1
	var current_cell
	if is_big_top_left(i):
		size = 2
	for y in range(size):
		for x in range(size):
			current_cell = wrap_cells(i + Vector2i(x, y))
			shape_cells.append(current_cell)
	return shape_cells


func get_tile_key(i : Vector2i) -> Array:
	var tile_key = [0]
	if is_big_top_left(i):
		tile_key = [1, 2, 3, 4]
	return tile_key


func get_correct_adjacent(i : Vector2i) -> Array:
	var correct_adjacent := []
	var wrapped := []
	if is_small_tile(i):
		if big_rotation == 0:
			correct_adjacent = [
			i - (2 * COLUMN_UNIT), i - COLUMN_UNIT - (2 * ROW_UNIT),
			i + ROW_UNIT, i - ROW_UNIT + COLUMN_UNIT
			]
		if big_rotation == 1:
			correct_adjacent = [
			i - ROW_UNIT - (2 * COLUMN_UNIT), i - COLUMN_UNIT + ROW_UNIT, i - (2 * ROW_UNIT)
			, i + COLUMN_UNIT
			]
	if is_big_top_left(i):
		if big_rotation == 0:
			correct_adjacent = [
			i - DIAGONAL_UNIT - COLUMN_UNIT, i + ROW_UNIT - COLUMN_UNIT, i + (2 * ROW_UNIT) - COLUMN_UNIT
			, i - ROW_UNIT, i - (2 * ROW_UNIT) + COLUMN_UNIT, i + DIAGONAL_UNIT + ROW_UNIT
			, i + (2 * COLUMN_UNIT), i + DIAGONAL_UNIT + COLUMN_UNIT
			]
		if big_rotation == 1:
			correct_adjacent = [
			i + ROW_UNIT - (2 * COLUMN_UNIT), i - ROW_UNIT - DIAGONAL_UNIT, i - COLUMN_UNIT
			, i + (2 * ROW_UNIT), i - ROW_UNIT + COLUMN_UNIT, i + DIAGONAL_UNIT + ROW_UNIT
			, i - ROW_UNIT + (2 * COLUMN_UNIT), i + DIAGONAL_UNIT + COLUMN_UNIT
			]
	for j in correct_adjacent:
		wrapped.append(wrap_cells(j))
	return wrapped


func get_linked_set(i : Vector2i) -> Array:
	var linked_set := [i, i + (ROW_WIDTH / 2), i + (COLUMN_LENGTH / 2), i + (DIAGONAL_SPAN / 2)]
	var wrapped:= []
	for j in linked_set:
		wrapped.append(wrap_cells(j))
	return wrapped


func audit_board() -> void:
	for i in spots.size():
		var status : int = -1
		if is_off(spots["S" + str(i)]["landmark"]):
			status = 0
		if is_on(spots["S" + str(i)]["landmark"]):
			status = 1
		if status != int(target_state["T" + str(i)]):
			get_child(Layers.WIN).visible = false
			return
	var first_win := false
	if LevelData.data[level_set]["lv" + str(get_parent().level_data_index)]["completed"] == false:
		first_win = true
	LevelData.data[level_set]["lv" + str(get_parent().level_data_index)]["completed"] = true
	get_child(Layers.WIN).visible = true
	if get_parent().level_data_index < LevelData.data[level_set].size() - 1:
		LevelData.data[level_set]["lv" + str(get_parent().level_data_index + 1)]["unlocked"] = true
	if first_win:
		SaveManager.save_game()


func check_board() -> void:
	for i in range(2):
		if get_child(Layers.WRONG + i).is_visible():
			return
	for i in spots.size():
		if is_off(spots["S" + str(i)]["landmark"]) or is_on(spots["S" + str(i)]["landmark"]):
			if int(is_on(spots["S" + str(i)]["landmark"])) != int(target_state["T" + str(i)]):
				get_child(Layers.WRONG).visible = true
				get_child(Layers.TIMER).start()
				return
	get_child(Layers.RIGHT).visible = true
	get_child(Layers.TIMER).start()

func get_current_board(mode : int) -> void:
	var history_store := []
	var dict : Dictionary = {}
	var stores : Array[String] = ["initial", "target", "current"]
	var caps : Array[String] = ["I", "T", "C"]
	var changes := 0

	if all_set:
		var note_set := []
		for i in get_child(-1).get_used_cells():
			note_set.append([i.x, i.y])
		if note_set != notes:
			LevelData.data[level_set]["lv" + str(get_parent().level_data_index)]["notes"] = note_set
			changes = 1

	for i in spots.size():
		var status : int = -1
		if is_off(spots["S" + str(i)]["landmark"]):
			status = 0
		if is_on(spots["S" + str(i)]["landmark"]):
			status = 1
		if mode == Gl.Modes.HISTORY:
			history_store.append(status)
		else:
			dict[caps[mode] + str(i)] = status
		if mode == Gl.Modes.CURRENT and not current_state.is_empty():
			changes += int(current_state["C" + str(i)] != status)
	if current_state.is_empty() or mode != Gl.Modes.CURRENT:
		changes = 1
	if mode == Gl.Modes.HISTORY:
		if history.size() > Gl.QUEUE_SIZE:
			history.pop_front()
		history.append(history_store)
		changes = 0
	if changes == 0:
		return
	LevelData.data[level_set]["lv" + str(get_parent().level_data_index)][stores[mode]] = dict.duplicate()
	SaveManager.save_game()


func set_state(i : Vector2i, tileset : Array, direction : String) -> void:
	var shape = get_shape_cells(i)
	var tile = get_tile_key(i)
	if tileset.is_empty():
		if direction == "back":
			if not (is_off(i) or is_on(i)):
				tileset = on_set
			if is_on(i):
				tileset = off_set
			if is_off(i):
				for j in shape.size():
					get_child(Layers.STATE).erase_cell(shape[j])
				return
		else:
			if not (is_off(i) or is_on(i)):
				tileset = off_set
			if is_off(i):
				tileset = on_set
			if is_on(i):
				for j in shape.size():
					get_child(Layers.STATE).erase_cell(shape[j])
				return
	for j in shape.size():
		get_child(Layers.STATE).set_cell(shape[j], tile_id, tileset[tile[j]], Gl.ROTS[spin_key[j]])


func toggle_laser(i, mode) -> void:
	var new_state : Vector2i
	var layer : int
	var spin := []
	var pair := []
	var coords := []
	var tile : Vector2i
	var type : Vector2i
	if mode == "line":
		tile = FRINGE_ON
		type = LINE_BEAM
	else:
		tile = FRINGE_CELL
		type = CELL_HOVER
	if is_fringe_off(i):
		new_state = tile
	else:
		new_state = FRINGE_OFF
	if is_column_square(i):
		layer = 0
		spin = [0, 4]
		pair = [Vector2i(i.x, -1), Vector2i(i.x, ROWS)]
		for j in range(ROWS):
			coords.append(Vector2i(i.x, j))
	else:
		layer = 1
		spin = [6, 2]
		pair = [Vector2i(-1, i.y), Vector2i(COLS, i.y)]
		for j in range(COLS):
			coords.append(Vector2i(j, i.y))
	for j in spin.size():
		get_child(Layers.FRINGE).set_cell(pair[j], tile_id, new_state, Gl.ROTS[spin[j]])
	if new_state != FRINGE_OFF:
		for j in coords:
			get_child(Layers.COLUMN + layer).set_cell(j, tile_id, type, Gl.ROTS[spin[0]])
	else:
		for j in coords:
			get_child(Layers.COLUMN + layer).erase_cell(j)


func _process(_delta) -> void:
	for i in range(2):
		get_child(Layers.HOVER + i).clear()

	if StateHandler.state != StateHandler.States.IN_GAME:
		return

	var mouse_pos := local_to_map(get_local_mouse_position())
	if is_fringe(mouse_pos):
		get_child(Layers.HOVER).set_cell(mouse_pos, tile_id, FRINGE_HOVER)

	for i in get_child(Layers.FRINGE).get_used_cells():
		if is_fringe_on(i):
			var line_set := []
			if is_column_square(i):
				line_set = x_cols[i.x]
			else:
				line_set = y_rows[i.y]
			for j in line_set:
				highlight_shapes(spots["S" + str(j)]["landmark"], hover_set)

	if is_on_map(mouse_pos):
		for i in range(2):
			if get_child(Layers.COLUMN + i).get_cell_atlas_coords(mouse_pos) == CELL_HOVER:
				get_child(Layers.CELL_HOVER).set_cell(mouse_pos, tile_id, SMALL_EX_HOVER) 
		var middle_cell = centralize_shapes(mouse_pos)
		if hover_mode == Hover_modes.ADJACENT:
			for i in get_correct_adjacent(middle_cell):
				highlight_shapes(i, hover_set)
		if hover_mode == Hover_modes.QUAD:
			for i in get_linked_set(middle_cell):
				highlight_shapes(i, hover_set)
		highlight_shapes(middle_cell, focus_set)


func highlight_shapes(i, tileset) -> void:
	var shape = get_shape_cells(i)
	var tile = get_tile_key(i)
	for j in shape.size():
		get_child(Layers.HOVER).set_cell(shape[j], tile_id, tileset[tile[j]], Gl.ROTS[spin_key[j]])


func is_small_tile(i : Vector2i) -> bool:
	return (big_rotation == 0 
	and ((2 * i.y) + i.x) % 5 == tiling_offset) or (big_rotation == 1 
	and ((2 * i.x) + i.y) % 5 == tiling_offset)


func is_big_top_left(i : Vector2i) -> bool:
	return ((big_rotation == 0 and is_small_tile(i + ROW_UNIT + DIAGONAL_UNIT)) 
	or (big_rotation == 1 and is_small_tile(i + (2 * ROW_UNIT))))

func is_landmark(i : Vector2i) -> bool:
	return is_small_tile(i) or is_big_top_left(i)

func is_on_map(i : Vector2i) -> bool:
	return(
		((i.x) >= 0 and (i.x) < COLS
		and (i.y) >= 0 and (i.y) < ROWS)
	)

func is_column_top(i : Vector2i) -> bool:
	return is_on_map(i + COLUMN_UNIT) and not is_on_map(i)

func is_column_bottom(i : Vector2i) -> bool:
	return is_on_map(i - COLUMN_UNIT) and not is_on_map(i)

func is_column_square(i : Vector2i) -> bool:
	return is_column_top(i) or is_column_bottom(i)

func is_row_left(i : Vector2i) -> bool:
	return is_on_map(i + ROW_UNIT) and not is_on_map(i)

func is_row_right(i : Vector2i) -> bool:
	return is_on_map(i - ROW_UNIT) and not is_on_map(i)

func is_row_square(i : Vector2i) -> bool:
	return is_row_left(i) or is_row_right(i)

func is_fringe(i : Vector2i) -> bool:
	return get_child(Layers.FRINGE).get_cell_source_id(i) != -1

func is_fringe_off(i : Vector2i) -> bool:
	return  get_child(Layers.FRINGE).get_cell_atlas_coords(i) == FRINGE_OFF

func is_fringe_on(i : Vector2i) -> bool:
	return  get_child(Layers.FRINGE).get_cell_atlas_coords(i) == FRINGE_ON

func is_locked(i : Vector2i) -> bool:
	return get_child(Layers.LOCKED).get_cell_source_id(i) != -1

func is_on(i : Vector2i) -> bool:
	return on_set.has(get_child(Layers.STATE).get_cell_atlas_coords(i))

func is_off(i : Vector2i) -> bool:
	return off_set.has(get_child(Layers.STATE).get_cell_atlas_coords(i))

func is_stateless(i : Vector2i) -> bool:
	return get_child(Layers.STATE).get_cell_source_id(i) == -1


func _on_timer_timeout() -> void:
	for i in range(2):
		get_child(Layers.WRONG + i).visible = false
