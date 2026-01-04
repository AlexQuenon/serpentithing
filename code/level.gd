@tool

class_name Level
extends Node

const SIZE = 10

const HEIGHT_MAP = [
	[9, 8, 7, 6, 6, 4, 4, 6, 7, 7],
	[5, 5, 5, 5, 5, 4, 4, 6, 3, 9],
	[5, 5, 6, 5, 4, 4, 4, 4, 4, 6],
	[4, 4, 6, 5, 4, 4, 4, 4, 4, 5],
	[6, 6, 6, 5, 3, 8, 3, 6, 6, 1],
	[5, 5, 5, 5, 3, 3, 3, 3, 5, 1],
	[5, 5, 5, 7, 5, 5, 3, 2, 1, 1],
	[7, 7, 7, 9, 9, 9, 7, 5, 3, 5],
	[7, 7, 7, 9, 7, 7, 7, 1, 1, 1],
	[8, 7, 7, 9, 7, 7, 9, 0, 5, 0]
]

const GOALS = [
	[9, 0],
	[4, 1],
	[9, 5],
	[3, 6],
	[8, 7],
	[1, 8],
	[1, 9],
	[3, 9],
	[6, 7],
	[9, 9],
]


static func coord_on_goal(coord : Vector3i):
	return [coord.x, coord.y] in GOALS and coord.z == HEIGHT_MAP[coord.x][coord.y] + 1
