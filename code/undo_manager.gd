extends Node

signal rollback_action(state)

var stack = []

func _process(_delta):
	if Input.is_action_just_pressed('undo'):
		if stack.size() > 1:
			stack.pop_back()
			rollback_action.emit(stack[stack.size() - 1])
			AudioManager.play_undo()
	elif Input.is_action_just_pressed('reset'):
		if stack.size() > 1:
			stack.resize(1)
			rollback_action.emit(stack[stack.size() - 1])
			AudioManager.play_undo()


func write_state(state):
	stack.append(state)
