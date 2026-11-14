extends Node2D


var click_pos := []
var color


func _input(event: InputEvent) -> void:
	if not (Input.is_action_pressed("interact") or Input.is_action_pressed("clear")):
		return

	if Input.is_action_pressed("interact"):
		click_pos.append([event.position, Color.WHITE])
	if Input.is_action_pressed("clear"):
		click_pos.append([event.position, Color.TRANSPARENT])
	queue_redraw()

func _draw() -> void:
	for point in click_pos:
		draw_circle(point[0], 4, point[1])
