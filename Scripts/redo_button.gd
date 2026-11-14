extends Button


func _on_pressed() -> void:
	SignalBus.redo_pressed.emit()
