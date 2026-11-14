extends TileMapLayer

const ROWS := 4
const COLS := 4
const CELL_SIZE := 84
const BORDER := 5
const OFFSET := Vector2i(25, 25)

enum Layers {
	LOCKED, NEW
}
const LOCKED_ICON := Vector2i(0, 0)
const NEW_ICON := Vector2i(1, 0)
const DATA_TILE := Vector2i(2, 0)
var tile_id := 0
var data_ref : Dictionary = {}


func _ready() -> void:
	SignalBus.state_changed.emit(StateHandler.States.TUTOR_MENU)
	SignalBus.rule_selected.connect(_on_rule_selected)
	data_ref = LevelData.data["rules"].duplicate()
	prime_tiles()
	set_level_state()


func is_different() -> bool:
	return data_ref != LevelData.data["rules"]


func prime_tiles() -> void:
	for y in range(ROWS):
		for x in range(COLS):
			set_cell(Vector2i(x, y), tile_id, DATA_TILE)


func set_level_state() -> void:
	for i in get_children():
		i.clear()
	for i in get_used_cells().size():
		if LevelData.data["rules"]["rl" + str(i)]["unlocked"] == false:
			get_child(Layers.LOCKED).set_cell(get_used_cells()[i], tile_id, LOCKED_ICON)
		if LevelData.data["rules"]["rl" + str(i)]["viewed"] == false:
			get_child(Layers.NEW).set_cell(get_used_cells()[i], tile_id, NEW_ICON)


func is_locked(i) -> bool:
	return get_child(Layers.LOCKED).get_cell_source_id(i) != -1


func _on_rule_selected(rule) -> void:
	if not is_locked(get_used_cells()[rule]):
		SignalBus.rule_needed.emit(rule)


func _on_visibility_changed() -> void:
	set_level_state()
