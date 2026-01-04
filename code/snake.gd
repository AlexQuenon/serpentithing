class_name Snake
extends Node

signal coordinates_updated(snake_coords, block_coords, last_direction, goals_met)
signal win

const Move = InputManager.Move

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
const FALL_SPEED = 0.15

var snake_coords = []
var block_coords = []
var last_direction : Move = Move.DOWN
var fall_timer : float = 0
var falling_snake : bool = false
var falling_blocks = []
var has_won = false

func _ready():
	add_segment(START_POSITION)
	emit_coordinates_updated_signal()
	UndoManager.rollback_action.connect(set_state)
	log_state_checkpoint()


func _process(delta):
	if has_won:
		return

	var blocks_on_goals_before = blocks_on_goal()
	var snake_on_goal_before = snake_coords.size() == 1 and Level.coord_on_goal(snake_coords[0])
	if blocks_are_falling():
		fall_timer += delta
		if fall_timer > FALL_SPEED:
			fall_timer = 0.0
			while blocks_are_falling():
				make_blocks_fall()
				flag_falling_blocks()
			AudioManager.play_landing()
			log_state_checkpoint()
	else:
		var move : Move = InputManager.get_move_action()
		if move != Move.NONE:
			if apply_move(move):
				emit_coordinates_updated_signal()
				if move == Move.DETACH:
					AudioManager.play_detach()
				else:
					AudioManager.play_move()

				flag_falling_blocks()
				if not blocks_are_falling():
					log_state_checkpoint()
			else:
				AudioManager.play_blocked()

	var blocks_on_goals_after = blocks_on_goal()
	var snake_on_goal_after = snake_coords.size() == 1 and Level.coord_on_goal(snake_coords[0])
	var new_blocks_on_goal = false
	var new_snake_on_goal = snake_on_goal_after and not snake_on_goal_before
	for i in blocks_on_goals_after:
		if i not in blocks_on_goals_before:
			new_blocks_on_goal = true
			break
	if snake_on_goal_after and blocks_on_goals_after.size() == SIZE - 1:
		AudioManager.play_win()
		has_won = true
		win.emit()
	elif new_snake_on_goal or new_blocks_on_goal:
		AudioManager.play_goal()


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
	has_won = false


func log_state_checkpoint():
	UndoManager.write_state(get_state())




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
		if i >= snake_coords.size():
			var curr = block_coords[i - snake_coords.size()] + ABOVE
			while curr in pushed_map:
				affected.append(pushed_map[curr])
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


func blocks_on_goal():
	var result = {}
	for i in range(block_coords.size()):
		if Level.coord_on_goal(block_coords[i]):
			result[i] = true
	return result


func emit_coordinates_updated_signal():
	var goals_met = count_goals()
	coordinates_updated.emit(snake_coords, block_coords, last_direction, goals_met)


func count_goals():
	return blocks_on_goal().size() + int(snake_coords.size() == 1 and Level.coord_on_goal(snake_coords[0]))
