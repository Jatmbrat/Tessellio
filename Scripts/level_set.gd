extends TileMapLayer

const ROWS := 5
const COLS := 5
const CELL_SIZE := 74
const BORDER := 5
const OFFSET := Vector2i(25, 25)

enum Layers {
	LOCKED, COMPLETE, HOVER, WIN
}
const HOVER_SET := [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)
	]
const LOCKED_ICON := Vector2i(3, 0)
const COMPLETE_ICON := Vector2i(3, 1)
const DATA_TILE := Vector2i(4, 0)
var tile_id := 0


func _ready() -> void:
	SignalBus.state_changed.emit(StateHandler.States.LEVEL_SELECT)
	SignalBus.level_selected.connect(_on_level_selected)
	SlopeChecker.cols = CELL_SIZE
	SlopeChecker.rows = CELL_SIZE
	prime_tiles()
	set_level_state()
	number_levels()


func prime_tiles() -> void:
	for y in range(ROWS):
		for x in range(COLS):
			set_cell(Vector2i(x, y), tile_id, DATA_TILE)


func set_level_state() -> void:
	var incomplete := 0
	for i in get_used_cells().size():
		if LevelData.data["default"]["lv" + str(i)]["unlocked"] == false:
			get_child(Layers.LOCKED).set_cell(get_used_cells()[i], tile_id, LOCKED_ICON)
		if LevelData.data["default"]["lv" + str(i)]["completed"] == true:
			get_child(Layers.COMPLETE).set_cell(get_used_cells()[i], tile_id, COMPLETE_ICON)
		else:
			incomplete += 1
	if incomplete == 0:
		get_child(Layers.WIN).visible = true


func number_levels() -> void:
	for i in get_used_cells().size():
		var level_num = Label.new()
		level_num.size = Vector2i(CELL_SIZE, CELL_SIZE)
		level_num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		level_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		level_num.add_theme_font_size_override("font_size", int(CELL_SIZE * .5))
		level_num.position = get_used_cells()[i] * CELL_SIZE
		if not is_locked(get_used_cells()[i]):
			level_num.text = str(i + 1)
		add_child(level_num)


func _process(_delta: float) -> void:
	get_child(Layers.HOVER).clear()
	var mouse_pos := local_to_map(get_local_mouse_position())
	if is_on_map(mouse_pos):
		SlopeChecker.position = mouse_pos * CELL_SIZE - OFFSET
		if SlopeChecker.is_inner_square(BORDER):
			get_child(Layers.HOVER).set_cell(mouse_pos, tile_id, HOVER_SET.pick_random())


func is_on_map(i) -> bool:
	return(
		((i.x) >= 0 and (i.x) < COLS
		and (i.y) >= 0 and (i.y) < ROWS)
	)


func is_locked(i) -> bool:
	return get_child(Layers.LOCKED).get_cell_source_id(i) != -1


func _on_level_selected(level) -> void:
	if not is_locked(get_used_cells()[level]):
		SignalBus.level_needed.emit(level)
