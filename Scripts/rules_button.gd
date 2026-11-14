extends Button


func _on_pressed() -> void:
	SignalBus.rule_selected.emit(get_index())
