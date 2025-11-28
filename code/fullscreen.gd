extends CheckButton


func _on_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)


func _process(_delta):
	# Handle cases where the window mode has changed outside of pressing the button
	if get_window().mode == DisplayServer.WINDOW_MODE_FULLSCREEN and not button_pressed:
		button_pressed = true
	elif button_pressed:
		button_pressed = false
