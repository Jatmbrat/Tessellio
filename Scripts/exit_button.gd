extends Button


func _on_pressed() -> void:
	SignalBus.exit_pressed.emit()
