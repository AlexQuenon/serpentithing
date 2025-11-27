extends Node

var stack = []

func _process(_delta):
	if Input.is_action_just_pressed('undo'):
		print("UNDOING")
	elif Input.is_action_just_pressed('reset'):
		print("RESETTING")
