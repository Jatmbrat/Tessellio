extends TileMapLayer

var tile_id := 0

var home := Vector2i(0, 0)
var draw_icon := Vector2i(0, 0)
var play_icon := Vector2i(1, 0)



func _ready() -> void:
	for i in range(2):
		toggle_icon()


func _input(event: InputEvent) -> void:
	if not (
		StateHandler.state == StateHandler.States.IN_GAME or StateHandler.state == StateHandler.States.DRAWING
	):
		return
	if event.is_action_pressed("Toggle Draw Mode"):
		toggle_icon()


func toggle_icon() -> void:
	var icon : Vector2i
	if get_cell_atlas_coords(home) == draw_icon:
		icon = play_icon
		SignalBus.state_changed.emit(StateHandler.States.IN_GAME)
	else:
		icon = draw_icon
		SignalBus.state_changed.emit(StateHandler.States.DRAWING)
	set_cell(home, tile_id, icon)


func _on_note_button_pressed() -> void:
	toggle_icon()


func _on_clear_button_pressed() -> void:
	get_parent().get_parent().get_child(-1).clear()


func _on_check_button_pressed() -> void:
	get_parent().get_parent().check_board()
