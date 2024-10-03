extends Node2D

func _ready():
	Player.disable()

func _input(event):
	if Input.is_action_just_pressed("pause"):
		# Skip cutscene
		_on_intro_animator_animation_finished(null)

func _on_intro_animator_animation_finished(anim_name):
	# Go to the tutorial scene
	RoomManager.goto("res://rooms/tutorial.tscn")
