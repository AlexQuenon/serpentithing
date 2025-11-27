class_name Snake
extends Node

signal coordinates_updated(snake_coords, block_coords, last_direction)

enum Move {
	NONE,
	UP,
	DOWN,
	LEFT,
	RIGHT,
	DETACH,
}

const MOVE_MAP = {
	Move.UP: Vector3i(0, -1, 0),
	Move.DOWN: Vector3i(0, 1, 0),
	Move.LEFT: Vector3i(-1, 0, 0),
	Move.RIGHT: Vector3i(1, 0, 0),
}
const ABOVE = Vector3i(0, 0, 1)
const BELOW = Vector3i(0, 0, -1)
const START_POSITION = Vector3i(0, 0, 10)
const START_DIRECTION = Move.DOWN
const SIZE = 10
const FALL_SPEED = 0.1

var snake_coords = []
var block_coords = []
var last_direction : Move = Move.DOWN
var fall_timer : float = 0
var falling_snake : bool = false
var falling_blocks = []
var awaiting_state_checkpoint = false

func _ready():
	add_segment(START_POSITION)
	emit_coordinates_updated_signal()
	UndoManager.rollback_action.connect(set_state)
	log_state_checkpoint()


func _process(delta):
	if blocks_are_falling():
		fall_timer += delta
		if fall_timer > FALL_SPEED:
			make_blocks_fall()
			fall_timer = 0.0
	else:
		if awaiting_state_checkpoint:
			log_state_checkpoint()
			awaiting_state_checkpoint = false

		var move : Move = get_input_action()
		if move != Move.NONE:
			if apply_move(move):
				# TODO: UNDO SAVE STATE
				# state get/set
				awaiting_state_checkpoint = true
				emit_coordinates_updated_signal()
				if move == Move.DETACH:
					AudioManager.play_detach()
				else:
					AudioManager.play_move()
			else:
				AudioManager.play_blocked()

	flag_falling_blocks()


func get_state():
	return [snake_coords.duplicate(), block_coords.duplicate(), last_direction]


func set_state(state):
	snake_coords = state[0].duplicate()
	block_coords = state[1].duplicate()
	last_direction = state[2]
	reset_implicit_state()
	emit_coordinates_updated_signal()


func reset_implicit_state():
	fall_timer = 0
	falling_snake = false
	falling_blocks = []
	awaiting_state_checkpoint = false


func log_state_checkpoint():
	UndoManager.write_state(get_state())


func get_input_action():
	if Input.is_action_just_pressed('detach'):
		return Move.DETACH
	if Input.is_action_just_pressed('ui_up'):
		return Move.UP
	if Input.is_action_just_pressed('ui_down'):
		return Move.DOWN
	if Input.is_action_just_pressed('ui_left'):
		return Move.LEFT
	if Input.is_action_just_pressed('ui_right'):
		return Move.RIGHT
	return Move.NONE


func apply_move(move : Move):
	match move:
		Move.DETACH:
			if snake_coords.size() == 1 or snake_coords.size() + block_coords.size() < SIZE:
				return false
			block_coords.push_back(snake_coords.pop_back())
		Move.UP, Move.DOWN, Move.LEFT, Move.RIGHT:
			if not push_blocks(move):
				return false
		_:
			return false

	# TODO: manage falling snakes and blocks (+towers)

	return true


func push_blocks(move : Move):
	var direction : Vector3i = MOVE_MAP[move]
	var universal_coords = snake_coords + block_coords
	var pushed_map = {}
	for i in range(universal_coords.size()):
		pushed_map[universal_coords[i]] = i

	var pushed = snake_coords[0] + direction
	var affected = []
	while pushed in universal_coords:
		var i = pushed_map[pushed]
		if i < snake_coords.size():
			if i == snake_coords.size() - 1:
				if snake_coords.size() == 2 or snake_coords.size() + block_coords.size() < SIZE:
					return false
				else:
					break
			else:
				return false
		else:
			affected.append(i)
		pushed += direction

	# Check if we pushed into a wall
	if (
		min(pushed.x, pushed.y) < 0 or
		Level.SIZE <= max(pushed.x, pushed.y) or
		Level.HEIGHT_MAP[pushed.x][pushed.y] >= pushed.z
	):
		return false

	# Include stacks of blocks in the pushed list
	# NOTE: This assumes there is no way to carry blocks on the snake
	for ii in range(affected.size()):
		var i = affected[ii]
		if i < snake_coords.size():
			var curr = block_coords[i - snake_coords.size()] + ABOVE
			while curr in universal_coords:
				affected.append(universal_coords[curr])
				curr += ABOVE

	# NOTE: Snake cannot push self and so these are only boxes
	for i in affected:
		block_coords[i - snake_coords.size()] += direction

	add_segment(snake_coords[0] + direction)
	last_direction = move

	return true


func make_blocks_fall():
	if falling_snake:
		for i in range(snake_coords.size()):
			snake_coords[i] += BELOW
	for i in falling_blocks:
		block_coords[i] += BELOW

	emit_coordinates_updated_signal()


func flag_falling_blocks():
	var block_map = {}
	for coord in snake_coords + block_coords:
		block_map[coord] = true

	falling_snake = true
	for coord in snake_coords:
		var curr = coord
		while curr in block_map:
			curr += BELOW
		if Level.HEIGHT_MAP[curr.x][curr.y] == curr.z:
			falling_snake = false
			break

	falling_blocks = []
	for i in range(block_coords.size()):
		var curr = block_coords[i]
		while curr in block_map:
			curr += BELOW
		if curr.z > Level.HEIGHT_MAP[curr.x][curr.y]:
			falling_blocks.append(i)


func blocks_are_falling():
	return falling_snake or falling_blocks


func add_segment(coordinates):
	snake_coords.push_front(coordinates)
	if snake_coords.size() + block_coords.size() > SIZE:
		snake_coords.pop_back()


func emit_coordinates_updated_signal():
	coordinates_updated.emit(snake_coords, block_coords, last_direction)
