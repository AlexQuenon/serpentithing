extends Label


func _on_snake_coordinates_updated(snake_coords, block_coords, last_direction, goals_met):
	if snake_coords.size() + block_coords.size() == 10:
		hide()
	else:
		show()
		text = "+%s" % (10 - snake_coords.size())
