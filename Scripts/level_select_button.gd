extends Button


func _on_pressed() -> void:
	SignalBus.level_selected.emit(get_index())
