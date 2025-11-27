extends Node2D


func _on_snake_coordinates_updated(snake_coords, block_coords, last_direction, goals_met):
	%Hidden.show()
	%Progress.show()
	%ProgressCount.text = "%s/10" % goals_met
	%Winner.hide()
	%Blocks.render(snake_coords, block_coords, last_direction)


func _on_snake_win():
	%Hidden.hide()
	%Progress.hide()
	%Winner.reset()
	%Winner.show()
