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
		var shadow_hints = {}
		for coords in snake_coords + box_coords:
			var xy = Vector2i(coords.x, coords.y)
			shadow_hints[xy] = max(shadow_hints.get(xy, 0), coords.z)
		layer.render(snake_coords, box_coords, last_direction, shadow_hints)
