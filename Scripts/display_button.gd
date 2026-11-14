extends Button


func _on_pressed() -> void:
	Options.set_display(get_index())
