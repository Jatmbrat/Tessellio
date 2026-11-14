extends Node

const TESS_BIG_SMALL = preload("res://Scenes/tess_gen.tscn")
const TESS_QUADS = preload("res://Scenes/tess_gen_quads.tscn")
const LEVELS_DEFAULT = preload("res://Scenes/level_select_default.tscn")
const RULES_PAGE = preload("res://Scenes/rules_page.tscn")
const OPTIONS_PAGE = preload("res://Scenes/options_menu.tscn")
const NOTES = preload("res://Scenes/note_map.tscn")
const EXIT_CHECK = preload("res://Scenes/confirm_quit.tscn")

const CONTROLS = preload("res://Assets/Levels/rules/rl0.png")
const RULE_ONE = preload("res://Assets/Levels/rules/rl1.png")
const RULE_TWO = preload("res://Assets/Levels/rules/rl2.png")
const RULE_THREE = preload("res://Assets/Levels/rules/rl3.png")
const RULE_FOUR = preload("res://Assets/Levels/rules/rl4.png")
const RULE_FIVE = preload("res://Assets/Levels/rules/rl5.png")
const RULE_SIX = preload("res://Assets/Levels/rules/rl6.png")
const RULE_SEVEN = preload("res://Assets/Levels/rules/rl7.png")
const RULE_EIGHT = preload("res://Assets/Levels/rules/rl8.png")
const RULE_NINE = preload("res://Assets/Levels/rules/rl9.png")
const RULE_TEN = preload("res://Assets/Levels/rules/rl10.png")
const RULE_ELEVEN = preload("res://Assets/Levels/rules/rl11.png")
const RULE_TWELVE = preload("res://Assets/Levels/rules/rl12.png")
const RULE_THIRTEEN = preload("res://Assets/Levels/rules/rl13.png")
const RULE_FOURTEEN = preload("res://Assets/Levels/rules/rl14.png")
const RULE_FIFTEEN = preload("res://Assets/Levels/rules/rl15.png")

var rule_images := [
	CONTROLS, RULE_ONE, RULE_TWO, RULE_THREE, RULE_FOUR, RULE_FIVE, RULE_SIX, RULE_SEVEN, RULE_EIGHT,
	RULE_NINE, RULE_TEN, RULE_ELEVEN, RULE_TWELVE, RULE_THIRTEEN, RULE_FOURTEEN, RULE_FIFTEEN
	]

const DEF_ZERO = preload("res://Assets/Levels/default/lv0.png")
const DEF_ONE = preload("res://Assets/Levels/default/lv1.png")
const DEF_TWO = preload("res://Assets/Levels/default/lv2.png")
const DEF_THREE = preload("res://Assets/Levels/default/lv3.png")
const DEF_FOUR = preload("res://Assets/Levels/default/lv4.png")
const DEF_FIVE = preload("res://Assets/Levels/default/lv5.png")
const DEF_SIX = preload("res://Assets/Levels/default/lv6.png")
const DEF_SEVEN = preload("res://Assets/Levels/default/lv7.png")
const DEF_EIGHT = preload("res://Assets/Levels/default/lv8.png")
const DEF_NINE = preload("res://Assets/Levels/default/lv9.png")
const DEF_TEN = preload("res://Assets/Levels/default/lv10.png")
const DEF_ELEVEN = preload("res://Assets/Levels/default/lv11.png")
const DEF_TWELVE = preload("res://Assets/Levels/default/lv12.png")
const DEF_THIRTEEN = preload("res://Assets/Levels/default/lv13.png")
const DEF_FOURTEEN = preload("res://Assets/Levels/default/lv14.png")
const DEF_FIFTEEN = preload("res://Assets/Levels/default/lv15.png")
const DEF_SIXEEN = preload("res://Assets/Levels/default/lv16.png")
const DEF_SEVENTEEN = preload("res://Assets/Levels/default/lv17.png")
const DEF_EIGHTEEN = preload("res://Assets/Levels/default/lv18.png")
const DEF_NINETEEN = preload("res://Assets/Levels/default/lv19.png")
const DEF_TWENTY = preload("res://Assets/Levels/default/lv20.png")
const DEF_TWENTYONE = preload("res://Assets/Levels/default/lv21.png")
const DEF_TWENTYTWO = preload("res://Assets/Levels/default/lv22.png")
const DEF_TWENTYTHREE = preload("res://Assets/Levels/default/lv23.png")
const DEF_TWENTYFOUR = preload("res://Assets/Levels/default/lv24.png")

var default_images := [
	DEF_ZERO, DEF_ONE, DEF_TWO, DEF_THREE, DEF_FOUR, DEF_FIVE, DEF_SIX, DEF_SEVEN, DEF_EIGHT, DEF_NINE, 
	DEF_TEN, DEF_ELEVEN, DEF_TWELVE, DEF_THIRTEEN, DEF_FOURTEEN, DEF_FIFTEEN, DEF_SIXEEN, DEF_SEVENTEEN,
	DEF_EIGHTEEN, DEF_NINETEEN, DEF_TWENTY, DEF_TWENTYONE, DEF_TWENTYTWO, DEF_TWENTYTHREE, DEF_TWENTYFOUR
	]


const KEY_LEVELS = [5, 6, 8, 11, 12, 13, 14, 15, 16, 17, 19, 22]
const LEVEL_RULES = [5, 9, 8, 13, 14, 7, 11, 10, 6, 4, 12, 15]

var boards : Array[PackedScene]
var board_types = [TESS_BIG_SMALL, TESS_QUADS]
var level_set := "default"
var level_data_index := 0
var stored_state := []


func _ready() -> void:
	boards.append_array(board_types)
	SignalBus.level_needed.connect(_on_level_needed)
	SignalBus.rule_needed.connect(_on_rule_needed)
	SignalBus.exit_pressed.connect(_on_exit_pressed)
	SignalBus.denied.connect(_on_back_button_pressed)


func load_level_select() -> void:
	get_child(0).get_current_board(Gl.Modes.CURRENT)
	get_child(0).queue_free()
	await get_child(0).tree_exited
	add_child(LEVELS_DEFAULT.instantiate())


func instantiate_board(board:PackedScene) -> void:
	var instance = board.instantiate()
	add_child(instance)


func _on_level_needed(level) -> void:
	get_child(-1).queue_free()
	await get_child(-1).tree_exited

	for i in KEY_LEVELS.size():
		if KEY_LEVELS[i] <= level:
			LevelData.data["rules"]["rl" + str(LEVEL_RULES[i])]["unlocked"] = true

	level_data_index = level
	var board_type = LevelData.data[level_set]["lv" + str(level_data_index)]["board"]
	instantiate_board(boards[board_type])

	var clues = Sprite2D.new()
	clues.centered = false
	clues.position = (Vector2(-1, -1) * get_child(0).CELL_SIZE) + get_child(0).BOARD_POSITION
	clues.texture = default_images[level]
	get_child(0).add_child(clues)
	get_child(0).add_child(NOTES.instantiate())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Options"):
		_on_options_button_pressed()
	if event.is_action_pressed("Rules"):
		_on_rules_button_pressed()
	if event.is_action_pressed("Close"):
		_on_exit_pressed()
	if event.is_action_pressed("Back out"):
		_on_back_button_pressed()


func _on_exit_pressed() -> void:
	if StateHandler.state == StateHandler.States.CONFIRM:
		leave()
	else:
		confirm_exit()


func leave() -> void:
	get_child(-1).queue_free()
	await get_child(-1).tree_exited
	get_child(-1).visible = true
	SignalBus.state_changed.emit(stored_state.back())
	if StateHandler.state == StateHandler.States.IN_GAME or StateHandler.state == StateHandler.States.DRAWING:
		get_child(0).get_current_board(Gl.Modes.CURRENT)
	get_tree().quit()


func confirm_exit() -> void:
	stored_state.append(StateHandler.state)
	SignalBus.state_changed.emit(StateHandler.States.NEUTRAL)
	get_child(-1).visible = false
	var confirm = EXIT_CHECK.instantiate()
	confirm.position = Vector2i(-32, -32)
	add_child(confirm)


func _on_options_button_pressed() -> void:
	if StateHandler.state == StateHandler.States.OPTIONS:
		leave_rules()
		return

	if StateHandler.state > StateHandler.States.PRE_TITLE and StateHandler.state < StateHandler.States.OPTIONS:
		stored_state.append(StateHandler.state)
		SignalBus.state_changed.emit(StateHandler.States.NEUTRAL)
		get_child(-1).visible = false
		var options = OPTIONS_PAGE.instantiate()
		options.position = Vector2i(-32, -32)
		add_child(options)


func _on_rules_button_pressed() -> void:
	if StateHandler.state == StateHandler.States.TUTOR_MENU:
		leave_rules()
		return

	if StateHandler.state == StateHandler.States.IN_TUTOR:
		return_to_rules()
		return

	if  StateHandler.state > StateHandler.States.PRE_TITLE and StateHandler.state < StateHandler.States.TUTOR_MENU:
		stored_state.append(StateHandler.state)
		SignalBus.state_changed.emit(StateHandler.States.NEUTRAL)
		get_child(0).visible = false

		var rules = RULES_PAGE.instantiate()
		rules.position = Vector2i(-32, -32)
		add_child(rules)


func _on_rule_needed(rule) -> void: 
	get_child(-1).visible = false
	var example = Sprite2D.new()
	example.centered = false
	example.position = Vector2i(-32, -32)
	example.texture = rule_images[rule]
	add_child(example)
	LevelData.data["rules"]["rl" + str(rule)]["viewed"] = true
	SignalBus.state_changed.emit(StateHandler.States.IN_TUTOR)


func return_to_rules() -> void:
	get_child(-1).queue_free()
	await get_child(-1).tree_exited
	
	get_child(-1).visible = true
	SignalBus.state_changed.emit(StateHandler.States.TUTOR_MENU)


func leave_rules() -> void:
	var saving := false
	var changes := 0
	if StateHandler.state == StateHandler.States.TUTOR_MENU:
		changes += int(get_child(-1).get_child(-1).get_child(-1).is_different())
	changes += int(Options.is_different())
	if changes != 0:
		saving = true

	get_child(-1).queue_free()
	await get_child(-1).tree_exited
	get_child(-1).visible = true
	SignalBus.state_changed.emit(stored_state.back())
	stored_state.pop_back()

	if saving:
		SaveManager.save_game()


func _on_back_button_pressed() -> void:
	if StateHandler.state == StateHandler.States.IN_GAME or StateHandler.state == StateHandler.States.DRAWING:
		SignalBus.state_changed.emit(StateHandler.States.NEUTRAL)
		load_level_select()
	if (
		StateHandler.state == StateHandler.States.TUTOR_MENU or StateHandler.state == StateHandler.States.OPTIONS
		or StateHandler.state == StateHandler.States.CONFIRM
	):
		leave_rules()
	if StateHandler.state == StateHandler.States.IN_TUTOR:
		return_to_rules()
