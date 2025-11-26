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
	%Tiles.clear()
	%WallDecoration.clear()
	%FaceDecoration.clear()
	%ShadowDecoration.clear()
	for i in range(Level.SIZE):
		for j in range(Level.SIZE):
			if sides_visible(i, j):
				%WallDecoration.set_cell(Vector2i(i, j), ATLAS_SOURCE, WALL_DECORATION_COORDS[layer_index])
			if Level.HEIGHT_MAP[i][j] == layer_index:
				if [i, j] in Level.GOALS:
					%Tiles.set_cell(Vector2i(i, j), ATLAS_SOURCE, GOAL_COORDS)
				else:
					%Tiles.set_cell(Vector2i(i, j), ATLAS_SOURCE, TILE_COORDS)
				if layer_index == 5:  # TODO: TEMP
					%FaceDecoration.set_cell(Vector2i(i, j), ATLAS_SOURCE, FACE_DECORATION_COORDS)
				if j == 4:  # TODO: TEMP
					%ShadowDecoration.set_cell(Vector2i(i, j), ATLAS_SOURCE, SHADOW_DECORATION_COORDS)


func sides_visible(i, j):
	if Level.HEIGHT_MAP[i][j] < layer_index:
		return false

	for coord in [[i + 1, j], [i, j + 1]]:
		if i >= Level.SIZE or j >= Level.SIZE or Level.HEIGHT_MAP[i][j] >= layer_index:
			return true
	return false

# TODO: %FaceDecoration.clear()
