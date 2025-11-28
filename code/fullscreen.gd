extends CheckButton


func _on_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)


func _process(_delta):
	if Input.is_action_just_pressed('fullscreen'):
		button_pressed = not button_pressed
