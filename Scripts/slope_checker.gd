extends TileMapLayer


var rows : int
var cols : int


# Slope variables
var upslope : int
var downslope : int


func draw_square() -> void:
	clear()
	for y in range(rows):
		for x in range(cols):
			set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	return


func  check_quadrants() -> void:
	var mouse_pos := local_to_map(get_local_mouse_position())
	if is_on_map(mouse_pos):
		if is_northwest(mouse_pos):
			upslope = 1
		if is_southeast(mouse_pos):
			upslope = 2
		if is_northeast(mouse_pos):
			downslope = 1
		if is_southwest(mouse_pos):
			downslope = 2
	return


func is_inner_square(border) -> bool:
	var mouse_pos := local_to_map(get_local_mouse_position())
	return(
		mouse_pos.x - border >= 0 and mouse_pos.x + border < cols
		and mouse_pos.y - border >= 0 and mouse_pos.y + border < rows
	)


func is_on_map(i) -> bool:
	return(
		i.x >= 0 and i.x < cols and i.y >= 0 and i.y < rows
	)

# Forty five degree slopes
func is_northwest(i) -> bool:
	return (i.x + i.y) < rows

func is_southeast(i) -> bool:
	return (i.x + i.y) >= rows

func is_northeast(i) -> bool:
	return i.x >= i.y

func is_southwest(i) -> bool:
	return i.x < i.y
