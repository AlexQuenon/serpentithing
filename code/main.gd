extends Node2D


func _on_snake_coordinates_updated(snake_coords, box_coords, last_direction):
	%Blocks.render(snake_coords, box_coords, last_direction)
