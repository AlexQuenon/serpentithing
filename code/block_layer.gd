@tool

class_name BlockLayer
extends Node2D

@export var layer_index = 0;

enum BoxState {
	CONNECTED = 0,
	OFF = 1,
	ON = 2,
}

enum Alignment {
	VERTICAL = 0,
	HORIZONTAL = 1,
}

const TILE_COORDS = Vector2i(0, 0)
const GOAL_COORDS = Vector2i(1, 0)

# HEAD_COORDS[BoxState][Alignment]
const HEAD_COORDS = [
	[Vector2i(0, 1), Vector2i(1, 1)],
	[Vector2i(0, 2), Vector2i(1, 2)],
	[Vector2i(0, 3), Vector2i(1, 3)],
]

const BODY_COORDS = Vector2i(2, 0)

# TAIL_COORDS[BoxState]
const TAIL_COORDS = [
	Vector2i(2, 1),
	Vector2i(2, 2),
	Vector2i(2, 3),
]

const WALL_DECORATION_COORDS = [
	Vector2i(5, 0),
	Vector2i(5, 3),
	Vector2i(4, 3),
	Vector2i(3, 3),
	Vector2i(5, 2),
	Vector2i(4, 2),
	Vector2i(3, 2),
	Vector2i(5, 1),
	Vector2i(4, 1),
	Vector2i(3, 1),
]

const SHADOW_DECORATION_COORDS = Vector2i(3, 0)
const FACE_DECORATION_COORDS = Vector2i(4, 0)

const TILE_LEVEL_OFFSET = Vector2(6, 6)
const ATLAS_SOURCE = 0

func _ready():
	position = (Level.SIZE - layer_index - 1) * TILE_LEVEL_OFFSET
	%WallDecoration.clear()
	for i in range(Level.SIZE):
		for j in range(Level.SIZE):
			if sides_visible(i, j):
				%WallDecoration.set_cell(Vector2i(i, j), ATLAS_SOURCE, WALL_DECORATION_COORDS[layer_index])
	render([], [], Snake.Move.DOWN)


func render(snake_coords, box_coords, direction):
	# TODO: cache snake/box locations to avoid overdoing it
	%Tiles.clear()
	%FaceDecoration.clear()
	%ShadowDecoration.clear()

	var active_floor = -1
	if snake_coords:
		active_floor = (snake_coords[0] as Vector3i).z

	for i in range(Level.SIZE):
		for j in range(Level.SIZE):
			if Level.HEIGHT_MAP[i][j] == layer_index:
				if [i, j] in Level.GOALS:
					%Tiles.set_cell(Vector2i(i, j), ATLAS_SOURCE, GOAL_COORDS)
				else:
					%Tiles.set_cell(Vector2i(i, j), ATLAS_SOURCE, TILE_COORDS)
				if layer_index == active_floor:  # TODO: TEMP
					%FaceDecoration.set_cell(Vector2i(i, j), ATLAS_SOURCE, FACE_DECORATION_COORDS)

	if layer_index == active_floor:
		for i in range(snake_coords.size()):
			var coords : Vector3i = snake_coords[i]
			var tile = get_snake_tile(i, snake_coords.size(), direction)
			%Tiles.set_cell(Vector2i(coords.x, coords.y), ATLAS_SOURCE, tile)

	for coords in box_coords:
		if layer_index == coords.z:
			var tile = get_box_tile(coords)
			%Tiles.set_cell(Vector2i(coords.x, coords.y), ATLAS_SOURCE, tile)

	# TODO: vvv Remember to do boxes too for brief falling duration
	# TODO: %ShadowDecoration.set_cell(Vector2i(i, j), ATLAS_SOURCE, SHADOW_DECORATION_COORDS)


func get_snake_tile(index, snake_size, direction):
	var alignment = Alignment.VERTICAL
	if direction in [Snake.Move.LEFT, Snake.Move.RIGHT]:
		alignment = Alignment.HORIZONTAL
	var state = BoxState.CONNECTED  # TODO: branch

	var tile = BODY_COORDS

	# TODO: check edge cases for different tiles
	if index == 0:
		tile = HEAD_COORDS[state][alignment]
	elif index == Snake.SIZE - 1:
		tile = TAIL_COORDS[state]
	return tile


func get_box_tile(coords):
	# TODO: check on/off
	return TAIL_COORDS[BoxState.OFF]


func sides_visible(i, j):
	if Level.HEIGHT_MAP[i][j] < layer_index:
		return false

	for coord in [[i + 1, j], [i, j + 1]]:
		if i >= Level.SIZE or j >= Level.SIZE or Level.HEIGHT_MAP[i][j] >= layer_index:
			return true
	return false

# TODO: %FaceDecoration.clear()
