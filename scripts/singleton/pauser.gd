extends CanvasLayer

@onready var pause_screen = $PauseScreen

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_screen.hide()
	
func _input(event):
	if Player.enabled and not RoomManager.is_transitioning:
		if Input.is_action_just_pressed("pause"):
			set_paused(not get_tree().paused)
	
	if Input.is_action_just_pressed("toggle_fullscreen"):
		get_window().mode = Window.MODE_FULLSCREEN if get_window().mode == Window.MODE_WINDOWED else Window.MODE_WINDOWED

func set_paused(value:bool):
	get_tree().paused = value
	pause_screen.visible = value

func _on_restart_pressed():
	set_paused(false)
	Stats.reset()
	Player.disable()
	Player.show()
	RoomManager.goto("res://rooms/tutorial.tscn")

func _on_title_pressed():
	set_paused(false)
	Stats.reset()
	Player.disable()
	Player.show()
	RoomManager.goto("res://title.tscn","",true,false)
	
