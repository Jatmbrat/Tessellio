extends Button


func _on_pressed() -> void:
	SignalBus.level_reset.emit()
	
