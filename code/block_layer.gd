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
	render([], [], Snake.Move.DOWN, {})


func render(snake_coords, block_coords, direction, shadow_hints):
	# TODO: cache snake/box locations to avoid overdoing it
	%Tiles.clear()
	%FaceDecoration.clear()
	%ShadowDecoration.clear()

	var active_floor = -1
	if snake_coords:
		active_floor = (snake_coords[0] as Vector3i).z


	if layer_index == active_floor:
		for i in range(snake_coords.size()):
			var coords : Vector3i = snake_coords[i]
			var tile = get_snake_tile(i, snake_coords[i], snake_coords.size(), block_coords.size(), direction)
			%Tiles.set_cell(Vector2i(coords.x, coords.y), ATLAS_SOURCE, tile)

	for coords in block_coords:
		if layer_index == coords.z:
			var tile = get_box_tile(coords)
			%Tiles.set_cell(Vector2i(coords.x, coords.y), ATLAS_SOURCE, tile)


	for i in range(Level.SIZE):
		for j in range(Level.SIZE):
			var coord = Vector2i(i, j)
			if Level.HEIGHT_MAP[i][j] == layer_index:
				if [i, j] in Level.GOALS:
					%Tiles.set_cell(Vector2i(i, j), ATLAS_SOURCE, GOAL_COORDS)
				else:
					%Tiles.set_cell(Vector2i(i, j), ATLAS_SOURCE, TILE_COORDS)
				if layer_index + 1 == active_floor:
					%FaceDecoration.set_cell(Vector2i(i, j), ATLAS_SOURCE, FACE_DECORATION_COORDS)
			if shadow_hints.get(coord, 0) > layer_index and %Tiles.get_cell_tile_data(coord) != null:
				%ShadowDecoration.set_cell(Vector2i(i, j), ATLAS_SOURCE, SHADOW_DECORATION_COORDS)


func get_snake_tile(index, coord, snake_size, box_size, direction):
	var alignment = Alignment.VERTICAL
	if direction in [Snake.Move.LEFT, Snake.Move.RIGHT]:
		alignment = Alignment.HORIZONTAL
	var state = BoxState.CONNECTED  # TODO: branch
	if snake_size == 1 and box_size == Snake.SIZE - snake_size:
		if coord_on_goal(coord):
			state = BoxState.ON
		else:
			state = BoxState.OFF

	var tile = BODY_COORDS

	# TODO: check edge cases for solo snake and activation state

	if index == 0:
		tile = HEAD_COORDS[state][alignment]
	elif index == Snake.SIZE - 1 - box_size:
		tile = TAIL_COORDS[state]
	return tile


func get_box_tile(coord):
	if coord_on_goal(coord):
		return TAIL_COORDS[BoxState.ON]
	return TAIL_COORDS[BoxState.OFF]


func coord_on_goal(coord):
	return [coord.x, coord.y] in Level.GOALS and coord.z == Level.HEIGHT_MAP[coord.x][coord.y] + 1


func sides_visible(i, j):
	if Level.HEIGHT_MAP[i][j] < layer_index:
		return false

	for coord in [[i + 1, j], [i, j + 1]]:
		if i >= Level.SIZE or j >= Level.SIZE or Level.HEIGHT_MAP[i][j] >= layer_index:
			return true
	return false

# TODO: %FaceDecoration.clear()
