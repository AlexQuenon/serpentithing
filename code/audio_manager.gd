extends Node

func set_mute(mute):
	AudioServer.set_bus_mute(0, mute)

func play_move():
	%Move.play()

func play_blocked():
	%Blocked.play()

func play_undo():
	%Undo.play()

func play_detach():
	%Detach.play()

func play_landing():
	%Landing.play()

func play_goal():
	%Goal.play()

func play_win():
	%Win.play()
