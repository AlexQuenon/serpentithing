extends Node2D

func render(snake_coords, box_coords, last_direction):
	for layer in [
		$"0",
		$"1",
		$"2",
		$"3",
		$"4",
		$"5",
		$"6",
		$"7",
		$"8",
		$"9",
		$"10",
	]:
		layer.render(snake_coords, box_coords, last_direction)
