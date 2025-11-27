extends Node2D


func _on_snake_coordinates_updated(snake_coords, block_coords, last_direction):
	%Winner.hide()
	%Blocks.render(snake_coords, block_coords, last_direction)


func _on_snake_win():
	%Winner.reset()
	%Winner.show()
