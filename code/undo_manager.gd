extends Node

signal rollback_action(state)

var stack = []

func _process(_delta):
	if Input.is_action_just_pressed('undo'):
		if stack.size() > 1:
			stack.pop_back()
			rollback_action.emit(stack[stack.size() - 1])
			AudioManager.play_undo()
		else:
			AudioManager.play_blocked()
	elif Input.is_action_just_pressed('reset'):
		if stack.size() > 1:
			stack.resize(1)
			rollback_action.emit(stack[stack.size() - 1])
			AudioManager.play_undo()
		else:
			AudioManager.play_blocked()


func write_state(state):
	stack.append(state)
