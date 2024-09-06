extends Node2D

func _on_intro_animator_animation_finished(anim_name):
	# Go to the tutorial scene
	RoomManager.goto("res://rooms/tutorial.tscn")
