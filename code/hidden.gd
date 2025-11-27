extends Label

const MESSAGE = "Space: Detach Tail"


func _on_snake_coordinates_updated(snake_coords, block_coords, last_direction, goals_met):
	if snake_coords.size() + block_coords.size() == 10:
		text = MESSAGE
	else:
		text = "+%s" % (10 - snake_coords.size())
