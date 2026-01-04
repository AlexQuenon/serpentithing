extends Node

enum Move {
	NONE,
	UP,
	DOWN,
	LEFT,
	RIGHT,
	DETACH,
}

enum Rollback {
	NONE,
	UNDO,
	RESET,
}

const MOVE_ACTIONS = {
	'detach': Move.DETACH,
	'up': Move.UP,
	'down': Move.DOWN,
	'left': Move.LEFT,
	'right': Move.RIGHT,
}

const ROLLBACK_ACTIONS = {
	'undo': Rollback.UNDO,
	'reset': Rollback.RESET,
}

const REPEAT_FIRST_TIMEOUT = 0.3
const REPEAT_ONGOING_TIMEOUT = 0.2

var timeout = 0.0
var held_key : String = ''


func _process(delta):
	for key in MOVE_ACTIONS.keys() + ROLLBACK_ACTIONS.keys():
		if Input.is_action_pressed(key):
			if held_key == key:
				timeout = max(0, timeout - delta)
			else:
				held_key = key
				timeout = REPEAT_FIRST_TIMEOUT
			break

func get_action(dict, default):
	for key in dict:
		if held_key == key and timeout == 0.0:
			timeout = REPEAT_ONGOING_TIMEOUT
			return dict[key]
		elif Input.is_action_just_pressed(key):
			timeout = REPEAT_FIRST_TIMEOUT
			return dict[key]
	return default

func get_move_action():
	return get_action(MOVE_ACTIONS, Move.NONE)

func get_rollback_action():
	return get_action(ROLLBACK_ACTIONS, Rollback.NONE)
