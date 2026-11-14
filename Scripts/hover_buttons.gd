extends TileMapLayer


func _ready() -> void:
	SignalBus.hover_changed.connect(_on_hover_changed)
	SignalBus.hover_changed.emit(get_parent().hover_mode)

func _on_hover_changed(mode) -> void:
	get_parent().hover_mode = mode
	get_parent().get_child(get_parent().Layers.GRID).visible = bool(mode % 2 != 0)
	clear()
	set_cell(Vector2i(mode, 0), 0, Vector2i(0, 0))
