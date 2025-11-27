extends CheckButton


func _on_toggled(toggled_on):
	AudioManager.set_mute(toggled_on)


func _process(_delta):
	if Input.is_action_just_pressed('mute'):
		button_pressed = not button_pressed
