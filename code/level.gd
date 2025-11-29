@tool

class_name Level
extends Node

const SIZE = 10

const HEIGHT_MAP = [
	[9, 8, 7, 7, 7, 4, 4, 6, 6, 6],
	[8, 7, 5, 5, 5, 4, 4, 6, 3, 9],
	[9, 7, 5, 5, 4, 4, 4, 4, 4, 6],
	[7, 6, 6, 5, 4, 4, 4, 4, 4, 5],
	[5, 6, 6, 5, 3, 8, 6, 6, 6, 0],
	[5, 5, 5, 5, 3, 3, 3, 3, 8, 0],
	[6, 6, 6, 6, 5, 5, 7, 3, 2, 5],
	[7, 7, 7, 9, 9, 7, 7, 5, 2, 2],
	[7, 7, 7, 9, 7, 7, 9, 1, 0, 0],
	[8, 7, 7, 9, 7, 7, 9, 2, 0, 0]
]

const GOALS = [
	[9, 0],
	[4, 1],
	[8, 4],
	[3, 6],
	[8, 7],
	[1, 8],
	[1, 9],
	[3, 9],
	[9, 7],
	[9, 9],
]


static func coord_on_goal(coord : Vector3i):
	return [coord.x, coord.y] in GOALS and coord.z == HEIGHT_MAP[coord.x][coord.y] + 1
