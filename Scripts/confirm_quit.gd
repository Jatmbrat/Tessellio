extends Node2D


func _ready() -> void:
	SignalBus.state_changed.emit(StateHandler.States.CONFIRM)
