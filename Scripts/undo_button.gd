extends Button


func _on_pressed() -> void:
	SignalBus.undo_pressed.emit()
