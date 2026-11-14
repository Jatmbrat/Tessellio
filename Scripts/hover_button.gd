extends Button


func _on_pressed() -> void:
	SignalBus.hover_changed.emit(get_index())
