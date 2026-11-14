extends Node


var save : Dictionary = {
	
}

var saved := [Options, LevelData]


func _ready() -> void:
	load_game()
	Options.set_display(Options.data["Anchor"])


func load_new() -> void:
	if not FileAccess.file_exists("res://Resources/defaults.json"):
		return
	var new_file = FileAccess.open("res://Resources/defaults.json", FileAccess.READ)
	while new_file.get_position() < new_file.get_length():
		var json_string = new_file.get_line()

		var json = JSON.new()

		var  parse_result = json.parse(json_string)
		if not parse_result == OK:
			continue

		save = json.data

	distribute_load()


func load_game() -> void:
	if not FileAccess.file_exists("user://savegame.save"):
		load_new()
		return
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		var json = JSON.new()

		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			continue

		save = json.data

	distribute_load()


func distribute_load() -> void:
	for i in saved.size():
		saved[i].data = save["Data_" + str(i)].duplicate()


func save_game() -> void:
	for i in saved.size():
		save["Data_" + str(i)] = saved[i].data.duplicate()
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_dict = save.duplicate()
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)
