extends Node

signal rollback_action(state)

const Rollback = InputManager.Rollback

var stack = []

func _process(_delta):
	var rollback : Rollback = InputManager.get_rollback_action()

	match rollback:
		Rollback.UNDO:
			if stack.size() > 1:
				stack.pop_back()
				rollback_action.emit(stack[stack.size() - 1])
				AudioManager.play_undo()
			else:
				AudioManager.play_blocked()
		Rollback.RESET:
			if stack.size() > 1:
				stack.append(stack[0])
				rollback_action.emit(stack[stack.size() - 1])
				AudioManager.play_undo()
			else:
				AudioManager.play_blocked()


func write_state(state):
	stack.append(state)
