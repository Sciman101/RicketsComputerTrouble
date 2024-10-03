extends CanvasLayer

@onready var pause_screen = $PauseScreen

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_screen.hide()
	
func _input(event):
	if Player.enabled and not RoomManager.is_transitioning:
		if Input.is_action_just_pressed("pause"):
			var pause = not get_tree().paused
			get_tree().paused = pause
			pause_screen.visible = pause
