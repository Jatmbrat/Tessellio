extends Node

enum States {
	PRE_TITLE, MAIN_SCREEN, LEVEL_SELECT, IN_GAME, DRAWING, TUTOR_MENU, IN_TUTOR, OPTIONS, CONFIRM, NEUTRAL
}
var state : int = 0

func _ready() -> void:
	SignalBus.state_changed.connect(_on_state_changed)


func _on_state_changed(game_state) -> void:
	state = game_state
